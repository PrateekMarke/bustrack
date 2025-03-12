
import 'package:bustrack/view/auth/sign_up_screen.dart';
import 'package:bustrack/view/screens/home_screen.dart';
import 'package:flutter/material.dart';

class Role extends StatelessWidget {
  const Role({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Choose Your Role',
            style: TextStyle(fontSize: 30),
          ),
          FilledButton(
              onPressed: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => HomeScreen()));
              },
              child: const Text(
                'Admin',
                style: TextStyle(color: Colors.white, fontSize: 18),
              )),
          FilledButton(
              onPressed: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => const SignUpScreen()));
              },
              child: const Text(
                'Superviser',
                style: TextStyle(color: Colors.white, fontSize: 18),
              )),
        ],
      ),
    );
  }
}
