// import 'dart:async';

// import 'package:bustrack/view/auth/student_login_screen.dart';
// import 'package:bustrack/view/screens/home_screen.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class SplashServices {
//   final auth = FirebaseAuth.instance;
//   Future<void> validateUser(context) async {
//     await Future.delayed(const Duration(seconds: 2));
//     User? user = auth.currentUser;
//     if (user != null) {
//       Navigator.pushReplacement(
//           context, MaterialPageRoute(builder: (_) => HomeScreen()));
//     } else {
//       Navigator.pushReplacement(
//           context, MaterialPageRoute(builder: (_) => StudentLoginScreen()));
//     }
//   }
// }
