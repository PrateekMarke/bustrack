
import 'package:bustrack/view/splash_screen/splash_services.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    SplashServices().validateUser(context);
  }

  @override
  Widget build(BuildContext context) {
    setState(() {});
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Bus Tracking App',
              style: TextStyle(fontSize: 30),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              'Book your Seat Now',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
