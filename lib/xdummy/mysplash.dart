import 'package:bustrack/xdummy/authscreen.dart';
import 'package:bustrack/xdummy/studentspages/trackbus.dart';
import 'package:bustrack/xdummy/driverpages/seatListScreen.dart';
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
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _navigateUser();
    });
  }

  Future<void> _navigateUser() async {
    User? user = _auth.currentUser;

    if (user == null) {
      _redirectTo(AuthScreen());
      return;
    }

    try {
      // ✅ Check if the user is a student
      DocumentSnapshot studentDoc = await _firestore.collection("students").doc(user.uid).get();

      if (studentDoc.exists) {
        // ✅ Fetch selected bus details
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

          print("🚍 Student Bus Details: $selectedBus");
          _redirectTo(TrackBusScreen(selectedBus: selectedBus));
          return;
        } else {
          print("⚠️ Bus not found for student!");
        }
      }

      // ✅ Check if the user is a driver
      DocumentSnapshot driverDoc = await _firestore.collection("driver").doc(user.uid).get();

      if (driverDoc.exists) {
        print("🚌 Driver found, redirecting...");
        _redirectTo(SeatListScreen());
        return;
      }

      // ❌ No user found in either collection → Go to AuthScreen
      print("⚠️ User not found in both 'students' & 'driver' collections!");
      _redirectTo(AuthScreen());
      
    } catch (e) {
      print("❌ Error: $e");
      _redirectTo(AuthScreen());
    }
  }

  // ✅ Safe Navigation Function
  void _redirectTo(Widget screen) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
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
