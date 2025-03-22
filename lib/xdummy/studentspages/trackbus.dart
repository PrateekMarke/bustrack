
import 'package:bustrack/xdummy/authscreen.dart';
import 'package:bustrack/xdummy/studentspages/studentbusstracking.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TrackBusScreen extends StatelessWidget {
  final Map<String, dynamic> selectedBus; // Selected Bus Info

  const TrackBusScreen({super.key, required this.selectedBus});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Track Bus"),
        backgroundColor: Colors.yellow,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("No new notifications!")),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
           
              Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AuthScreen(),
              ),
            );
            },
          ),
        ],
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navigate to Bus Tracking Screen with Selected Bus
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TrackingMapScreen(selectedBus: selectedBus),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            textStyle: const TextStyle(fontSize: 18),
          ),
          child: const Text("🚍 Track My Bus"),
        ),
      ),
    );
  }
}
