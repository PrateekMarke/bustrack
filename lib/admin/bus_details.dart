import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BusDetailsScreen extends StatelessWidget {
  final String busId;

  const BusDetailsScreen({super.key, required this.busId});

  Future<Map<String, dynamic>> _fetchDetails() async {
    // Fetch driver (bus) details using busId
    final driverDoc =
        await FirebaseFirestore.instance.collection("driver").doc(busId).get();

    // Fetch students where bus_id matches this driver (bus)
    final studentQuery = await FirebaseFirestore.instance
        .collection("students")
        .where("bus_id", isEqualTo: busId)
        .get();

    return {
      "driver": driverDoc.data(),
      "students": studentQuery.docs.map((doc) => doc.data()).toList(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bus Details")),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("❌ Failed to load bus details."));
          }

          final driver = snapshot.data!["driver"];
          final students = snapshot.data!["students"] as List<dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("🚌 Bus & Driver Information",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                _infoTile("Bus Name", driver["bus_name"] ?? "N/A"),
                _infoTile("Driver Name", driver["name"] ?? "N/A"),
                _infoTile("Contact", driver["contact"] ?? "N/A"),
                _infoTile("Seats", driver["seats"]?.toString() ?? "N/A"),

                const Divider(height: 30),
                const Text("👩‍🎓 Assigned Students",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),

                if (students.isEmpty)
                  const Text("No students assigned to this bus."),
                for (var student in students)
                  Card(
                    child: ListTile(
                      title: Text(student["name"] ?? "Unknown"),
                      subtitle: Text(
                          "${student["branch"] ?? "Branch"} - Year ${student["year"] ?? "?"}"),
                      trailing: Text(student["contact"] ?? ""),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoTile(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text("$title: ",
              style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
