import 'package:bustrack/view/auth/student_login_screen.dart';
import 'package:bustrack/view/screens/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthController with ChangeNotifier {
  FirebaseAuth _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  User? _user;
  String? _role;

  User? get user => _user;
  String? get role => _role;

  AuthController() {
    _auth.authStateChanges().listen((User? user) async {
      _user = user;
      if (user != null) {
        final userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          final userData = userDoc.data();
          _role = userData?['role'];
        } else {
          _role = null;
        }
      }
      notifyListeners();
    });
  }

  Future<void> signInWithEmail(
    String email,
    String password,
    BuildContext context,
  ) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = userCredential.user;
      final userDoc =
          await _firestore.collection('users').doc(_user!.uid).get();
      if (userDoc.exists) {
        final userData = userDoc.data();
        _role = userData?['role'];
      } else {
        _role = null;
      }
      notifyListeners();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );
    } catch (e) {
      print("Error logging in: $e");
    }
  }

  Future<void> createAccount(
    String name,
    String email,
    String password,
    BuildContext context,
    String role,
    String vehicleNo,
  ) async {
    _isLoading = true;
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (_auth.currentUser != null) {
        await _firestore.collection('users').doc(_auth.currentUser!.uid).set({
          'name': name,
          'email': email,
          'password': password,
          'role': role,
          if (role == 'Admin') 'vehicleNo': vehicleNo,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account Created Successfully...')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
        );
      } else {
        throw Exception("Failed to create user.");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut(context) async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => StudentLoginScreen()),
    );
  }
}
