import 'package:bustrack/xdummy/studentspages/bus_selection.dart';
import 'package:flutter/material.dart';

class BusDetailsCard extends StatelessWidget {
  final Map<String, dynamic> bus;

  const BusDetailsCard({super.key, required this.bus});

  @override
  Widget build(BuildContext context) {
    // ✅ Convert `seat_data` from Map to List
    List<Map<String, dynamic>> seatData = [];
    if (bus["seat_data"] is Map) {
      seatData = (bus["seat_data"] as Map<String, dynamic>)
          .values
          .map((seat) => seat as Map<String, dynamic>)
          .toList();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView( // ✅ Prevents Overflow
        child: Column(
          mainAxisSize: MainAxisSize.min, // ✅ Ensures it doesn't expand unnecessarily
          children: [
            Text(
              "🚌 ${bus["bus_name"] ?? "Unknown Bus"}", 
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text("👨‍✈️ Driver: ${bus["name"] ?? "N/A"}"),
            Text("📞 Contact: ${bus["contact"] ?? "N/A"}"),
            Text("🪑 Seats: ${bus["seats"] ?? 0}"),
            const SizedBox(height: 15),

            // ✅ Display Seat Availability
            const Text("Seat Status", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            seatData.isEmpty
                ? const Text("No seat data available.", style: TextStyle(color: Colors.red))
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: seatData.map<Widget>((seat) {
                      return Chip(
                        label: Text(seat["student_name"] ?? "Unknown"),
                        backgroundColor: (seat["status"] == "Empty") ? Colors.green : Colors.red,
                        labelStyle: const TextStyle(color: Colors.white),
                      );
                    }).toList(),
                  ),

            const SizedBox(height: 15),

            // ✅ Select Bus Button
        ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BusSelectionScreen(selectedBus: bus),
      ),
    );
  },
  child: const Text("Choose This Bus"),
  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
),

          ],
        ),
      ),
    );
  }
}
