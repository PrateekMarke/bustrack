import 'package:bustrack/view/screens/location.dart'; // Import LocationService
import 'package:bustrack/xdummy/mapscreen.dart'; // Import MapScreen for manual selection
import 'package:bustrack/xdummy/multimapscreen.dart';
import 'package:bustrack/xdummy/studentspages/bus_selection.dart';
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

  LatLng? _selectedLocation; // Store selected location
  bool _isLoading = false; // Track loading state

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final LocationService _locationService = LocationService(); // ✅ Location Service

  bool _isButtonEnabled = false; // Track button state

  // ✅ Validate input fields and update button state
  void _validateFields() {
    setState(() {
      _isButtonEnabled = _nameController.text.isNotEmpty &&
          _contactController.text.isNotEmpty &&
          _branchController.text.isNotEmpty &&
          _yearController.text.isNotEmpty &&
          _selectedLocation != null;
    });
  }

  // ✅ Save student details to Firestore
  Future<void> saveStudentDetails() async {
    if (!_isButtonEnabled) return;

    setState(() => _isLoading = true); // Show loading

    try {
      User? user = _auth.currentUser;
      if (user == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("User not logged in!")));
        }
        return;
      }

      String uid = user.uid;

      await _firestore.collection("students").doc(uid).set({
        "name": _nameController.text,
        "contact": int.parse(_contactController.text),
        "branch": _branchController.text,
        "year": _yearController.text,
        "latitude": _selectedLocation!.latitude.toString(),
        "longitude": _selectedLocation!.longitude.toString(),
        "bus_id": "", // Default, can be updated when assigned to a bus
        "timestamp": FieldValue.serverTimestamp(),
      });
        await _firestore.collection("student_location").doc(uid).set({
        "latitude": _selectedLocation!.latitude,
        "longitude": _selectedLocation!.longitude,
        "timestamp": FieldValue.serverTimestamp(),
      });


      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("✅ Student details saved!")));

        // ✅ Navigate back after saving details
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false); // Hide loading
    }
  }

  // ✅ Get Current Location without opening map
  Future<void> getCurrentLocation() async {
    setState(() => _isLoading = true);

    LatLng? location = await _locationService.getCurrentLocation( context); // No MapController needed

    if (location != null) {
      setState(() {
        _selectedLocation = location;
        _validateFields();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("📍 Location Found: ${location.latitude}, ${location.longitude}")),
        );
          Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BusSelectionScreen(selectedBus: {},)),
        );
      }
    }

    setState(() => _isLoading = false);
  }

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_validateFields);
    _contactController.addListener(_validateFields);
    _branchController.addListener(_validateFields);
    _yearController.addListener(_validateFields);
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
      appBar: AppBar(title: Text("Student Details"), backgroundColor: Colors.yellow),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _nameController, decoration: InputDecoration(labelText: "Name")),
            TextField(controller: _contactController, keyboardType: TextInputType.phone, decoration: InputDecoration(labelText: "Contact Number")),
            TextField(controller: _branchController, decoration: InputDecoration(labelText: "Branch")),
            TextField(controller: _yearController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: "Year")),

            SizedBox(height: 20),

            // ✅ Select Location from Map Button
            // ElevatedButton.icon(
            //   icon: Icon(Icons.map),
            //   label: Text(_selectedLocation == null ? "Select Location from Map" : "📍 Location Selected"),
            //   onPressed: () async {
            //     final LatLng? location = await Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (context) => Mapscreen()),
            //     );

            //     if (location != null) {
            //       setState(() {
            //         _selectedLocation = location;
            //         _validateFields();
            //       });
            //     }
            //   },
            // ),

            SizedBox(height: 10),

            // ✅ Get Current Location Button (without map)
            ElevatedButton.icon(
              icon: Icon(Icons.gps_fixed),
              label: Text(_selectedLocation == null ? "Get Current Location" : "📍 Location Found"),
              onPressed: _isLoading ? null : getCurrentLocation,
            ),

            SizedBox(height: 20),

            // ✅ Save Button
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _isButtonEnabled ? saveStudentDetails : null,
                    child: Text("Save Details"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isButtonEnabled ? Colors.blue : Colors.grey,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
