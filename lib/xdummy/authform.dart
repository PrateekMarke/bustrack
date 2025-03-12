import 'package:bustrack/xdummy/driverscreen.dart';
import 'package:bustrack/xdummy/homescreen.dart';
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
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isLogin = true;
  bool isLoading = false;

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

      // Navigate based on role (Student or Driver)
      if (widget.userType == "Student") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Myhome()), // Student Page
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DriverDetailsScreen()), // Driver Page
        );
      }

    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "An error occurred")),
      );
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
