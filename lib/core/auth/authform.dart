import 'package:bustrack/admin/adminscreen.dart';
import 'package:bustrack/core/driverpages/driverscreen.dart';
import 'package:bustrack/core/driverpages/seatListScreen.dart';
import 'package:bustrack/core/studentspages/studentscreen.dart';
import 'package:bustrack/core/studentspages/trackbus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthForm extends StatefulWidget {
  final String userType;

  AuthForm({required this.userType});

  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isLogin = true;
  bool isLoading = false;

  final List<String> allowedAdminEmails = [
    "admin1@gmail.edu",
    "admin2@example.com",
  ];

  void authenticate() async {
    setState(() => isLoading = true);
    try {
      UserCredential userCredential;
      if (isLogin) {
        userCredential = await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      }

      User? user = userCredential.user;
      if (user == null) return;

      /// ✅ Admin Flow (check email before proceeding)
     else if (widget.userType == "Admin") {
  QuerySnapshot adminSnapshot = await _firestore.collection("admin").get();

  bool isFirstAdmin = adminSnapshot.docs.isEmpty;

  if (!isFirstAdmin && !allowedAdminEmails.contains(user.email)) {
    await _auth.signOut();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Access denied. Not an authorized admin.")),
    );
    setState(() => isLoading = false);
    return;
  }

  DocumentSnapshot adminDoc =
      await _firestore.collection("admin").doc(user.uid).get();

  if (adminDoc.exists) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AdminDashboardScreen()),
    );
  }
  else{
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AdminDashboardScreen()),
    );
  }
  return;
}


      /// ✅ Student Flow
      if (widget.userType == "Student") {
        DocumentSnapshot studentDoc =
            await _firestore.collection("students").doc(user.uid).get();

        if (studentDoc.exists) {
          String busId = studentDoc["bus_id"];
          if (busId.isNotEmpty) {
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

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      TrackBusScreen(selectedBus: selectedBus),
                ),
              );
              return;
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Bus not found!")),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("No bus assigned!")),
            );
          }
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => StudentDetailsScreen()),
          );
        }
      }

      /// ✅ Driver Flow
      else if (widget.userType == "Driver") {
        DocumentSnapshot driverDoc =
            await _firestore.collection("driver").doc(user.uid).get();

        if (driverDoc.exists) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => SeatListScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => DriverDetailsScreen()),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? "An error occurred")));
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "${widget.userType} ${isLogin ? 'Login' : 'Sign Up'}",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),

          TextField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: "Email",
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 10),

          TextField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: "Password",
              border: OutlineInputBorder(),
            ),
            obscureText: true,
          ),
          SizedBox(height: 20),

          isLoading
              ? CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: authenticate,
                  child: Text(isLogin ? "Login" : "Sign Up"),
                ),

          TextButton(
            onPressed: () => setState(() => isLogin = !isLogin),
            child: Text(
              isLogin
                  ? "Don't have an account? Sign up"
                  : "Already have an account? Login",
            ),
          ),
        ],
      ),
    );
  }
}
