import 'package:bustrack/xdummy/driverpages/driverscreen.dart';
import 'package:bustrack/xdummy/driverpages/seatListScreen.dart';
import 'package:bustrack/xdummy/studentspages/studentscree.dart';
import 'package:bustrack/xdummy/studentspages/trackbus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  // ✅ Authenticate & Redirect
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

      if (widget.userType == "Student") {
        // ✅ Check if student details exist in Firestore
        DocumentSnapshot studentDoc = await _firestore.collection("students").doc(user.uid).get();

        if (studentDoc.exists) {
          // Student data exists → Redirect to Bus Selection
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => TrackBusScreen(selectedBus: {},)));
        } else {
          // No student data → Redirect to StudentDetailsScreen
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => StudentDetailsScreen()));
        }
      } else {
        // ✅ Driver Flow (Unchanged)
        DocumentSnapshot driverDoc = await _firestore.collection("driver").doc(user.uid).get();

        if (driverDoc.exists) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SeatListScreen()));
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DriverDetailsScreen()));
        }
      }

    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? "An error occurred")));
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
          Text("${widget.userType} ${isLogin ? 'Login' : 'Sign Up'}", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),

          TextField(
            controller: _emailController,
            decoration: InputDecoration(labelText: "Email", border: OutlineInputBorder()),
          ),
          SizedBox(height: 10),

          TextField(
            controller: _passwordController,
            decoration: InputDecoration(labelText: "Password", border: OutlineInputBorder()),
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
            child: Text(isLogin ? "Don't have an account? Sign up" : "Already have an account? Login"),
          ),
        ],
      ),
    );
  }
}
