import 'package:bustrack/xdummy/authscreen.dart';
import 'package:bustrack/xdummy/chatscreen.dart';
import 'package:bustrack/xdummy/studentspages/studentbusstracking.dart';
import 'package:flutter/material.dart';

class TrackBusScreen extends StatelessWidget {
  final Map<String, dynamic> selectedBus; // Selected Bus Info

  const TrackBusScreen({super.key, required this.selectedBus});

  @override
  Widget build(BuildContext context) {
    print("Selected Bus Data: $selectedBus"); // ✅ Debugging print statement

    // ✅ Fetch bus_id safely from selectedBus
    String? busId = selectedBus['id']?.toString();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Track Bus"),
        backgroundColor: Colors.yellow,
        actions: [
          IconButton(
            icon: const Icon(Icons.chat),
            onPressed: () {
              print("Bus ID: $busId"); // ✅ Print busId for debugging
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
            print("Navigating to TrackingMapScreen with busId: $busId"); // ✅ Debugging print
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
