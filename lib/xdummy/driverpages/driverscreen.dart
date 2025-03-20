import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:bustrack/xdummy/mapscreen.dart';
import 'package:bustrack/xdummy/driverpages/seatListScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DriverDetailsScreen extends StatefulWidget {
  const DriverDetailsScreen({super.key});

  @override
  State<DriverDetailsScreen> createState() => _DriverDetailsScreenState();
}

class _DriverDetailsScreenState extends State<DriverDetailsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _busNameController = TextEditingController();
  final TextEditingController _seatsController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();

  LatLng? _selectedLocation;
  bool _isLoading = false;
  bool _isButtonEnabled = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _validateFields() {
    setState(() {
      _isButtonEnabled = _nameController.text.isNotEmpty &&
          _busNameController.text.isNotEmpty &&
          _seatsController.text.isNotEmpty &&
          _contactController.text.isNotEmpty &&
          _selectedLocation != null;
    });
  }
Future<void> saveDriverDetails() async {
  if (!_isButtonEnabled) return;

  setState(() => _isLoading = true);

  try {
    User? user = _auth.currentUser;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User not logged in!")),
        );
      }
      return;
    }

    String uid = user.uid;
    int seatCount = int.parse(_seatsController.text);
    
    // ✅ Force Firestore to store as a Map instead of a List
    Map<String, dynamic> seatsData = {};  
    for (int i = 1; i <= seatCount; i++) {  // 🔥 Start from 1 instead of 0
      seatsData[i.toString()] = { // 🔥 Use "1", "2", etc., as keys
        "student_id": "",
        "student_name": "Seat $i",
        "status": "Empty",
      };
    }

    await _firestore.collection("driver").doc(uid).set({
      "name": _nameController.text,
      "bus_name": _busNameController.text,
      "seats": seatCount,
      "contact": _contactController.text,
      "latitude": _selectedLocation!.latitude,
      "longitude": _selectedLocation!.longitude,
      "timestamp": FieldValue.serverTimestamp(),
      "seats_data": seatsData, // ✅ Firestore now stores it as a Map
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Details saved successfully!")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SeatListScreen()),
      );
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}


  @override
  void initState() {
    super.initState();
    _nameController.addListener(_validateFields);
    _busNameController.addListener(_validateFields);
    _seatsController.addListener(_validateFields);
    _contactController.addListener(_validateFields);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _busNameController.dispose();
    _seatsController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Driver Details"), backgroundColor: Colors.yellow),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(controller: _nameController, decoration: const InputDecoration(labelText: "Name")),
              TextField(controller: _busNameController, decoration: const InputDecoration(labelText: "Bus Name")),
              TextField(controller: _seatsController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Seats")),
              TextField(controller: _contactController, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: "Contact Number")),

              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.map),
                label: Text(_selectedLocation == null ? "Select Location" : "Location Selected"),
                onPressed: () async {
                  final LatLng? location = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyMapscreen()),
                  );

                  if (location != null) {
                    setState(() {
                      _selectedLocation = location;
                      _validateFields();
                    });
                  }
                },
              ),

              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _isButtonEnabled ? saveDriverDetails : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isButtonEnabled ? Colors.blue : Colors.grey,
                      ),
                      child: const Text("Save Details"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
