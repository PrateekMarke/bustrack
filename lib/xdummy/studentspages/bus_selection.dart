import 'package:bustrack/xdummy/studentspages/busmapscreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class BusSelectionScreen extends StatefulWidget {
  final Map<String, dynamic> selectedBus;

  const BusSelectionScreen({super.key, required this.selectedBus});

  @override
  _BusSelectionScreenState createState() => _BusSelectionScreenState();
}

class _BusSelectionScreenState extends State<BusSelectionScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  Future<void> _selectBus() async {
    setState(() => _isLoading = true);

    try {
      User? user = _auth.currentUser;
      if (user == null) return;

      String studentId = user.uid;  
      String studentName = user.displayName ?? "Unknown";  

      DocumentReference busDoc = _firestore.collection("driver").doc(widget.selectedBus["id"]);

      DocumentSnapshot busSnapshot = await busDoc.get();
      if (!busSnapshot.exists) return;

      Map<String, dynamic> seatData = Map<String, dynamic>.from(busSnapshot["seats_data"] ?? {});

      // ✅ Find the first available seat
      String? selectedSeatKey;
      seatData.forEach((key, value) {
        if (value["status"] == "Empty" && selectedSeatKey == null) {
          selectedSeatKey = key;
        }
      });

      if (selectedSeatKey != null) {
        String seatKey = selectedSeatKey!; // ✅ Ensures non-nullable String

        seatData[seatKey] = {
          "student_id": studentId,
          "student_name": studentName,
          "status": "Present",
        };

        await busDoc.update({"seats_data": seatData});

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Bus selected successfully!")),
        );

        // ✅ Navigate to the Student Map Screen after selection
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BusMapScreen()), 
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No available seats!")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Selected Bus")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Bus Name: ${widget.selectedBus["bus_name"]}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text("Driver Name: ${widget.selectedBus["name"]}"),
            Text("Contact: ${widget.selectedBus["contact"]}"),
            Text("Total Seats: ${widget.selectedBus["seats"]}"),
            const SizedBox(height: 20),

            // ✅ Display Seat Availability
            const Text("Seat Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            if (widget.selectedBus["seats_data"] != null && widget.selectedBus["seats_data"] is Map)
              Expanded(
                child: ListView(
                  children: (widget.selectedBus["seats_data"] as Map<String, dynamic>).entries.map((entry) {
                    final seat = entry.value as Map<String, dynamic>;
                    return ListTile(
                      title: Text("Seat: ${seat["student_name"]}"),
                      subtitle: Text("Status: ${seat["status"]}"),
                      trailing: seat["status"] == "Empty"
                          ? Icon(Icons.event_seat, color: Colors.green)
                          : Icon(Icons.close, color: Colors.red),
                    );
                  }).toList(),
                ),
              )
            else
              const Text("No seat data available", style: TextStyle(color: Colors.red)),

            const SizedBox(height: 20),

            // ✅ First Button: Assign seat and navigate to Map Screen
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _selectBus,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    child: const Text("Choose This Bus"),
                  ),

            const SizedBox(height: 10),

            // ✅ Second Button: Navigate to Map Screen without seat selection
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => BusMapScreen()), 
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text("Select Bus"),
            ),
          ],
        ),
      ),
    );
  }
}
