import 'package:bustrack/xdummy/mapscreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
 

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

  LatLng? _selectedLocation; // Store selected location

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isButtonEnabled = false; // Track button state

  // ✅ Validate input fields and update button state
  void _validateFields() {
    setState(() {
      _isButtonEnabled = _nameController.text.isNotEmpty &&
          _busNameController.text.isNotEmpty &&
          _seatsController.text.isNotEmpty &&
          _contactController.text.isNotEmpty &&
          _selectedLocation != null;
    });
  }

  // ✅ Save driver details to Firestore
Future<void> saveDriverDetails() async {
  try {
    User? user = _auth.currentUser;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("User not logged in!")));
      }
      return;
    }

    String uid = user.uid;

    await _firestore.collection("drivers").doc(uid).set({
      "name": _nameController.text,
      "bus_name": _busNameController.text,
      "seats": int.parse(_seatsController.text),
      "contact": _contactController.text,
      "latitude": _selectedLocation!.latitude,
      "longitude": _selectedLocation!.longitude,
      "timestamp": FieldValue.serverTimestamp(),
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Details saved successfully!")));
      Navigator.pop(context); // ✅ Only navigate if widget is still mounted
    }

  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    }
  }
}


  @override
  void initState() {
    super.initState();

    // Add listeners to update button state when text changes
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
      appBar: AppBar(title: Text("Driver Details"), backgroundColor: Colors.yellow),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: _busNameController,
              decoration: InputDecoration(labelText: "Bus Name"),
            ),
            TextField(
              controller: _seatsController,
              decoration: InputDecoration(labelText: "Seats"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _contactController,
              decoration: InputDecoration(labelText: "Contact Number"),
              keyboardType: TextInputType.phone,
            ),

            SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(Icons.map),
              label: Text(_selectedLocation == null ? "Select Location" : "Location Selected"),
              onPressed: () async {
                // Navigate to map screen and get selected location
                final LatLng? location = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyMapscreen()),
                );

                if (location != null) {
                  setState(() {
                    _selectedLocation = location;
                    _validateFields(); // Revalidate after location selection
                  });
                }
              },
            ),

            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isButtonEnabled ? saveDriverDetails : null, // Disable if fields are incomplete
              child: Text("Save Details"),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isButtonEnabled ? Colors.blue : Colors.grey, // Change color based on state
              ),
            ),
          ],
        ),
      ),
    );
  }
}
