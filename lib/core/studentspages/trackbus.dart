import 'package:bustrack/core/auth/authscreen.dart';
import 'package:bustrack/core/chatscreen.dart';
import 'package:bustrack/core/studentspages/studentbusstracking.dart';
import 'package:flutter/material.dart';

class TrackBusScreen extends StatelessWidget {
  final Map<String, dynamic> selectedBus; 

  const TrackBusScreen({super.key, required this.selectedBus});

  @override
  Widget build(BuildContext context) {
    print("Selected Bus Data: $selectedBus"); 

    String? busId = selectedBus['id']?.toString();
    String driverName = selectedBus['name'] ?? "Unknown";
    String busName = selectedBus['bus_name'] ?? "Unknown";
    String contact = selectedBus['contact'] ?? "N/A";
    int seatCount = selectedBus['seats'] ?? 0;

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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Driver Information",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text("👤 Driver: $driverName", style: const TextStyle(fontSize: 16)),
                    Text("🚌 Bus Name: $busName", style: const TextStyle(fontSize: 16)),
                    Text("📞 Contact: $contact", style: const TextStyle(fontSize: 16)),
                    Text("💺 Seats: $seatCount", style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Center(
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
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  
                ),
                child: const Text(
                  "🚍 Track My Bus",
                  
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
