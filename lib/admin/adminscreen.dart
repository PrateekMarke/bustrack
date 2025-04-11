
import 'package:bustrack/admin/adminbustracking.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bustrack/core/auth/authscreen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => AuthScreen()),
    );
  }

  Future<void> _deleteBus(String busId) async {
    try {
      // Delete bus from 'driver' collection
      await _firestore.collection("driver").doc(busId).delete();

      // Delete connected students with this bus_id
      final studentSnapshot = await _firestore
          .collection("students")
          .where("bus_id", isEqualTo: busId)
          .get();

      for (var doc in studentSnapshot.docs) {
        await doc.reference.delete();
      }

      // Optionally: Delete from 'driver_locations' collection
      await _firestore.collection("driver_locations").doc(busId).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("🗑️ Bus and related data deleted")),
      );
    } catch (e) {
      print("❌ Error deleting bus: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed to delete bus: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection("driver").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("❌ Error loading buses"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final buses = snapshot.data!.docs;

          if (buses.isEmpty) {
            return const Center(child: Text("🚌 No buses available"));
          }

          return ListView.builder(
            itemCount: buses.length,
            itemBuilder: (context, index) {
              final bus = buses[index];
              final busData = bus.data() as Map<String, dynamic>;

              return ListTile(
                title: Text(busData["bus_name"] ?? "Unknown Bus"),
                subtitle: Text("Driver: ${busData["name"] ?? "No Name"}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.location_on, color: Colors.blue),
                      onPressed: () {
                        final fullBusData = {
                          "id": bus.id,
                          ...busData,
                        };
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AdminBusTrackingScreen(
                              busData: fullBusData,
                            ),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _deleteBus(bus.id);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
