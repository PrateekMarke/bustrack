import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SeatListScreen extends StatefulWidget {
  @override
  _SeatListScreenState createState() => _SeatListScreenState();
}

class _SeatListScreenState extends State<SeatListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    String driverId = _auth.currentUser!.uid; // Get current driver ID

    return Scaffold(
      appBar: AppBar(title: Text("Seat List")),
      body: StreamBuilder(
        stream: _firestore.collection("drivers").doc(driverId).collection("seats").snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No seats assigned yet."));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var seat = snapshot.data!.docs[index];
              String seatId = seat.id;
              String studentName = seat["student_name"];
              String studentId = seat["student_id"];
              bool isPresent = seat["present"];

              return ListTile(
                title: Text(studentName, style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Student ID: $studentId"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Present"),
                    Switch(
                      value: isPresent,
                      onChanged: (value) {
                        _updateAttendance(driverId, seatId, value);
                      },
                    ),
                    Text("Absent"),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _updateAttendance(String driverId, String seatId, bool isPresent) async {
    await _firestore.collection("drivers").doc(driverId).collection("seats").doc(seatId).update({
      "present": isPresent,
    });
  }
}
