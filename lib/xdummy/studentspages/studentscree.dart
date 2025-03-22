import 'package:bustrack/view/screens/location.dart'; 
import 'package:bustrack/xdummy/studentspages/trackbus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class StudentDetailsScreen extends StatefulWidget {
  const StudentDetailsScreen({super.key});

  @override
  State<StudentDetailsScreen> createState() => _StudentDetailsScreenState();
}

class _StudentDetailsScreenState extends State<StudentDetailsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _branchController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();

  LatLng? _selectedLocation;
  bool _isLoading = false;
  bool _isButtonEnabled = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final LocationService _locationService = LocationService();

  List<Map<String, dynamic>> _busList = []; // List of available buses
  Map<String, dynamic>? _selectedBus; // Selected bus

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_validateFields);
    _contactController.addListener(_validateFields);
    _branchController.addListener(_validateFields);
    _yearController.addListener(_validateFields);
    _fetchBuses();
  }

  // ✅ Fetch available buses from Firestore
  Future<void> _fetchBuses() async {
    QuerySnapshot querySnapshot = await _firestore.collection("driver").get();
    setState(() {
      _busList = querySnapshot.docs.map((doc) {
        return {
          "id": doc.id,
          "bus_name": doc["bus_name"],
          "name": doc["name"],
          "contact": doc["contact"],
          "seats": doc["seats"],
          "seats_data": doc["seats_data"],
        };
      }).toList();
    });
  }

  // ✅ Validate input fields and update button state
  void _validateFields() {
    setState(() {
      _isButtonEnabled = _nameController.text.isNotEmpty &&
          _contactController.text.isNotEmpty &&
          _branchController.text.isNotEmpty &&
          _yearController.text.isNotEmpty &&
          _selectedLocation != null &&
          _selectedBus != null;
    });
  }

  // ✅ Get Current Location
  Future<void> getCurrentLocation() async {
    setState(() => _isLoading = true);

    LatLng? location = await _locationService.getCurrentLocation(context);

    if (location != null) {
      setState(() {
        _selectedLocation = location;
        _validateFields();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("📍 Location Found: ${location.latitude}, ${location.longitude}")),
        );
      }
    }

    setState(() => _isLoading = false);
  }

  // ✅ Save Student Details to Firestore & Assign Seat (Start from Index 1)
  Future<void> _saveStudentDetails() async {
    if (_auth.currentUser == null) {
      print("❌ User not logged in!");
      return;
    }

    try {
      String userId = _auth.currentUser!.uid; // Get current user ID

      // ✅ Save Student Details in Firestore
      await _firestore.collection("students").doc(userId).set({
        "name": _nameController.text,
        "contact": _contactController.text,
        "branch": _branchController.text,
        "year": _yearController.text,
        "latitude": _selectedLocation!.latitude,
        "longitude": _selectedLocation!.longitude,
        "bus_name": _selectedBus!["bus_name"],
        "bus_id": _selectedBus!["id"], // Store bus ID for tracking
        "timestamp": FieldValue.serverTimestamp(),
      });

      print("✅ Student details saved successfully!");

      // ✅ Fetch Bus Data to Update Seats
      DocumentSnapshot busDoc = await _firestore.collection("driver").doc(_selectedBus!["id"]).get();
      Map<String, dynamic> busData = busDoc.data() as Map<String, dynamic>;

      // ✅ Ensure seats_data is a Map (Matching DriverDetailsScreen)
      Map<String, dynamic> seatsData = {};
      if (busData["seats_data"] is Map) {
        seatsData = Map<String, dynamic>.from(busData["seats_data"]);
      } else {
        print("❌ Error: seats_data is in an unknown format!");
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("❌ Invalid seat data in Firestore!")));
        return;
      }

      // ✅ Find the first empty seat and assign the student (Start from Index 1)
      bool assigned = false;
      for (int i = 1; i <= seatsData.length; i++) {
        if (seatsData[i.toString()]["status"] == "Empty") {
          seatsData[i.toString()] = {
            "student_id": userId,
            "student_name": _nameController.text,
            "status": "Present"
          };
          assigned = true;
          break; // ✅ Stop after assigning the first available seat
        }
      }

      if (!assigned) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("⚠ No empty seats available!")));
        return;
      }

      // ✅ Update Firestore with the updated seat list
      await _firestore.collection("driver").doc(_selectedBus!["id"]).update({
        "seats_data": seatsData,
        "timestamp": FieldValue.serverTimestamp(),
      });

      print("✅ Student assigned to seat successfully!");
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("✅ Seat assigned successfully!")));

      // ✅ Navigate to TrackBusScreen after saving data
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TrackBusScreen(selectedBus: _selectedBus!),
        ),
      );
    } catch (e) {
      print("❌ Error saving student details: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed to save student details: $e")),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _branchController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Student Details"), backgroundColor: Colors.yellow),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: "Name")),
            TextField(controller: _contactController, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: "Contact Number")),
            TextField(controller: _branchController, decoration: const InputDecoration(labelText: "Branch")),
            TextField(controller: _yearController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Year")),

            const SizedBox(height: 20),

            // ✅ Bus Selection Dropdown
            DropdownButtonFormField<Map<String, dynamic>>(
              value: _selectedBus,
              decoration: const InputDecoration(labelText: "Choose Bus"),
              items: _busList.map((bus) {
                return DropdownMenuItem(
                  value: bus,
                  child: Text(bus["bus_name"]),
                );
              }).toList(),
              onChanged: (bus) {
                setState(() {
                  _selectedBus = bus;
                  _validateFields();
                });
              },
            ),

            const SizedBox(height: 10),

            ElevatedButton.icon(
              icon: const Icon(Icons.gps_fixed),
              label: Text(_selectedLocation == null ? "Get Current Location" : "📍 Location Found"),
              onPressed: _isLoading ? null : getCurrentLocation,
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _isButtonEnabled ? _saveStudentDetails : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isButtonEnabled ? Colors.blue : Colors.grey,
              ),
              child: const Text("Next"),
            ),
          ],
        ),
      ),
    );
  }
}
