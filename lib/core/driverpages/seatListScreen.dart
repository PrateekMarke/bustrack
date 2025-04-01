import 'dart:async';
import 'package:bustrack/core/auth/authscreen.dart';
import 'package:bustrack/core/chatscreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class SeatListScreen extends StatefulWidget {
  const SeatListScreen({super.key});

  @override
  State<SeatListScreen> createState() => _SeatListScreenState();
}

class _SeatListScreenState extends State<SeatListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  int _seatCount = 0;
  List<Map<String, dynamic>> _seats = [];
  bool _isTracking = false;
  Timer? _timer;

  User? _user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _fetchSeatCount();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
  Future<void> _fetchSeatCount() async {
    try {
      String uid = _auth.currentUser!.uid;
      DocumentSnapshot driverDoc =
          await _firestore.collection("driver").doc(uid).get();

      if (driverDoc.exists && driverDoc.data() != null) {
        int seatCount = driverDoc["seats"] ?? 0;
        Map<String, dynamic> seatData = Map<String, dynamic>.from(
          driverDoc["seats_data"] ?? {},
        );

        setState(() {
          _seatCount = seatCount;

          _seats = List.generate(seatCount, (index) {
            String key = "${index + 1}";
            return seatData.containsKey(key)
                ? seatData[key] as Map<String, dynamic>
                : {
                  "student_id": "S${index + 1}",
                  "student_name": "Seat ${index + 1}",
                  "status": "Empty",
                };
          });
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    }
  }

  void _openChatScreen() {
    if (_auth.currentUser != null) {
      String busId = _auth.currentUser!.uid;

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ChatScreen(busId: busId)),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("User not logged in!")));
    }
  }

  void _updateStatus(int index, String newStatus) {
    setState(() {
      _seats[index]["status"] = newStatus;
    });
  }

  // ✅ Save seat data to Firestore
  Future<void> _saveSeatData() async {
    try {
      String uid = _auth.currentUser!.uid;

      await _firestore.collection("driver").doc(uid).update({
        "seats_data": _seats,
        "timestamp": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Seat details saved successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    }
  }
  void _updateDriverLocation() async {
    if (_user == null) return;

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    FirebaseFirestore.instance
        .collection("driver_locations")
        .doc(_user!.uid)
        .set({
          "latitude": position.latitude,
          "longitude": position.longitude,
          "timestamp": FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  void _startTracking() {
    setState(() {
      _isTracking = true;
    });

    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      _updateDriverLocation();
    });
  }

  void _stopTracking() {
    if (mounted) {
      setState(() {
        _isTracking = false;
      });
    }
    _timer?.cancel();
  }

  void _logout() async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AuthScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Seat List"),
        backgroundColor: Colors.yellow,
        actions: [
          IconButton(
            icon: Icon(Icons.chat, color: Colors.black),
            onPressed: _openChatScreen,
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Colors.black),
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              "Total Seats: $_seatCount",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child:
                _seatCount == 0
                    ? Center(child: CircularProgressIndicator())
                    : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1.2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: _seatCount,
                        itemBuilder: (context, index) {
                          return Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _seats[index]["student_name"],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text("ID: ${_seats[index]["student_id"]}"),
                                  SizedBox(height: 10),
                                  Expanded(
                                    child: DropdownButton<String>(
                                      value: _seats[index]["status"],
                                      onChanged: (String? newValue) {
                                        if (newValue != null) {
                                          _updateStatus(index, newValue);
                                        }
                                      },
                                      items:
                                          [
                                            "Empty",
                                            "Absent",
                                            "Present",
                                          ].map<DropdownMenuItem<String>>((
                                            String value,
                                          ) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: _saveSeatData,
            child: Text("Save Seat Details"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          ),
          SizedBox(height: 10),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_isTracking) {
            _stopTracking();
          } else {
            _startTracking();
          }
        },
        backgroundColor: _isTracking ? Colors.red : Colors.green,
        child: Icon(_isTracking ? Icons.stop : Icons.play_arrow),
      ),
    );
  }
}
