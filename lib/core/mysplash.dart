import 'package:bustrack/core/auth/authscreen.dart';
import 'package:bustrack/core/studentspages/trackbus.dart';
import 'package:bustrack/core/driverpages/seatListScreen.dart';
import 'package:bustrack/admin/adminscreen.dart'; 
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

    if (user != null) {
      print("✅ User Logged In: ${user.uid}");

      DocumentSnapshot studentDoc =
          await _firestore.collection("students").doc(user.uid).get();

      if (studentDoc.exists) {
        String busId = studentDoc["bus_id"];
        print("🚌 Found Bus ID: $busId for student ${user.uid}");

        DocumentSnapshot busDoc =
            await _firestore.collection("driver").doc(busId).get();

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

          print("🚍 Bus Details Fetched Successfully: $selectedBus");

          Future.delayed(Duration(milliseconds: 500), () {
            _redirectTo(TrackBusScreen(selectedBus: selectedBus));
          });

        } else {
          print("⚠️ No Bus Found for ID: $busId!");
          Future.delayed(Duration(milliseconds: 500), () {
            _redirectTo(AuthScreen());
          });
        }
      } else {
        print("⚠️ No Student Data Found for UID: ${user.uid}");
        DocumentSnapshot driverDoc =
            await _firestore.collection("driver").doc(user.uid).get();

        if (driverDoc.exists) {
          print("✅ User is a Driver. Redirecting...");
          Future.delayed(Duration(milliseconds: 500), () {
            _redirectTo(SeatListScreen());
          });
        } else {
          // ✅ Admin flow added here without changing rest
          DocumentSnapshot adminDoc =
              await _firestore.collection("admin").doc(user.uid).get();

          if (adminDoc.exists) {
            print("👑 User is an Admin. Redirecting...");
            Future.delayed(Duration(milliseconds: 500), () {
              _redirectTo(AdminDashboardScreen());
            });
          } else {
            print("❌ User is neither Student, Driver, nor Admin!");
            Future.delayed(Duration(milliseconds: 500), () {
              _redirectTo(AuthScreen());
            });
          }
        }
      }
    } else {
      print("❌ No Logged-in User. Redirecting to AuthScreen.");
      Future.delayed(Duration(milliseconds: 500), () {
        _redirectTo(AuthScreen());
      });
    }
  }

  void _redirectTo(Widget screen) {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => screen),
      );
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
