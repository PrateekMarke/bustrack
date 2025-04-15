import 'dart:ui';
import 'package:bustrack/core/auth/authscreen.dart';
import 'package:bustrack/core/chatscreen.dart';
import 'package:bustrack/core/studentspages/studentbusstracking.dart';
import 'package:flutter/material.dart';

class TrackBusScreen extends StatelessWidget {
  final Map<String, dynamic> selectedBus;

  const TrackBusScreen({super.key, required this.selectedBus});

  @override
  Widget build(BuildContext context) {
    String? busId = selectedBus['id']?.toString();
    String driverName = selectedBus['name'] ?? "Unknown";
    String busName = selectedBus['bus_name'] ?? "Unknown";
    String contact = selectedBus['contact'] ?? "N/A";
    int seatCount = selectedBus['seats'] ?? 0;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text("Track Bus", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0F1115),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat, color: Colors.white),
            onPressed: () {
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
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => AuthScreen()),
              );
            },
          ),
        ],
      ),
      backgroundColor: const Color(0xFF0F1115),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.05),
                Colors.white.withOpacity(0.02),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Driver Info",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _infoRow("👤", "Driver: $driverName"),
                        const SizedBox(height: 10),
                        _infoRow("🚌", "Bus Name: $busName"),
                        const SizedBox(height: 10),
                        _infoRow("📞", "Contact: $contact"),
                        const SizedBox(height: 10),
                        _infoRow("💺", "Seats: $seatCount"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Track My Bus Button
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TrackingMapScreen(selectedBus: selectedBus),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueAccent.withOpacity(0.6),
                            offset: const Offset(0, 4),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          "🚌 Track My Bus",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String emoji, String text) {
    return Row(
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ],
    );
  }
}
