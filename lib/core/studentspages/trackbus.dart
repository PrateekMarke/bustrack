import 'package:bustrack/core/auth/authscreen.dart';
import 'package:bustrack/core/chatscreen.dart';
import 'package:bustrack/core/studentspages/studentbusstracking.dart';
import 'package:flutter/material.dart';

class TrackBusScreen extends StatelessWidget {
  final Map<String, dynamic> selectedBus; // Selected Bus Info

  const TrackBusScreen({super.key, required this.selectedBus});

  @override
  Widget build(BuildContext context) {
    print("Selected Bus Data: $selectedBus"); 
    String? busId = selectedBus['id']?.toString();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Track Bus"),
        backgroundColor: Colors.yellow,
        actions: [
          IconButton(
            icon: const Icon(Icons.chat),
            onPressed: () {
              print("Bus ID: $busId"); 
              if (busId != null && busId.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(busId: busId),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Bus ID not found! Cannot open chat.")),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              Navigator.pushReplacement(
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
            print("Navigating to TrackingMapScreen with busId: $busId"); 
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TrackingMapScreen(selectedBus: selectedBus),
              ),
            );
          },
          child: const Text("🚍 Track My Bus"),
        ),
      ),
    );
  }
}
