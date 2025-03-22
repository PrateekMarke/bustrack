
import 'package:bustrack/xdummy/authscreen.dart';
import 'package:bustrack/xdummy/studentspages/trackbus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    // Ensure navigation happens after the first frame
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _navigateUser();
    });
  }

Future<void> _navigateUser() async {
  User? user = _auth.currentUser;

  if (user != null) {
    // ✅ Fetch student details from 'students' collection
    DocumentSnapshot studentDoc = await _firestore.collection("students").doc(user.uid).get();

    if (studentDoc.exists) {
      // ✅ Fetch the selected bus details using 'bus_id'
      String busId = studentDoc["bus_id"];

      DocumentSnapshot busDoc = await _firestore.collection("driver").doc(busId).get();

      if (busDoc.exists) {
        Map<String, dynamic> selectedBus = {
          "id": busDoc.id,
          "bus_name": busDoc["bus_name"],
          "name": busDoc["name"],
          "contact": busDoc["contact"],
          "seats": busDoc["seats"],
          "seats_data": busDoc["seats_data"],
          "latitude": busDoc["latitude"],
          "longitude": busDoc["longitude"],
        };

        print("🚍 Bus Details: $selectedBus");

        // ✅ Navigate to TrackBusScreen with bus details
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TrackBusScreen(selectedBus: selectedBus),
          ),
        );
      } else {
        print("⚠️ Bus not found!");
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) => AuthScreen(),
        ));
      }
    } else {
      print("⚠️ Student not found in 'students' collection!");
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) => AuthScreen(),
      ));
    }
  } else {
    Navigator.pushReplacement(context, MaterialPageRoute(
      builder: (context) => AuthScreen(),
    ));
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
