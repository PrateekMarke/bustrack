
import 'package:bustrack/controller/firebase_controller.dart';
import 'package:bustrack/model/seat_arrengement_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'attendance_confirmation_screen.dart';

class BookingScreen extends StatefulWidget {
  final SeatingArrengement parkingSpace;

  const BookingScreen({required this.parkingSpace});

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  FirebaseController _firebaseService = FirebaseController();
  User? _user = FirebaseAuth.instance.currentUser;
  String? userRole;
  TextEditingController _messageController = TextEditingController();
  List<Map<String, String>> selectedStudents = [];
  List<Map<String, dynamic>> availableStudents = [];

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
    _fetchSelectedStudents();
    _fetchAvailableStudents();
  }

  Future<void> _fetchUserRole() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(_user?.uid)
        .get();
    setState(() {
      userRole = userDoc['role'];
    });
  }

  Future<void> _fetchSelectedStudents() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('vehicle')
        .doc(widget.parkingSpace.id)
        .get();
    List<String> studentUIDs = List<String>.from(doc['selectedStudentUIDs']);
    List<Map<String, String>> students = [];
    for (String uid in studentUIDs) {
      DocumentSnapshot studentDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      students.add({
        'uid': uid,
        'stud_name': studentDoc['stud_name'],
      });
    }
    setState(() {
      selectedStudents = students;
    });
  }

  Future<void> _fetchAvailableStudents() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'Student')
        .get();
    List<Map<String, dynamic>> students = querySnapshot.docs
        .map((doc) => {
              'uid': doc.id,
              'stud_name': doc['stud_name'],
            })
        .toList();
    setState(() {
      availableStudents = students.where((student) {
        return !selectedStudents
            .any((selected) => selected['uid'] == student['uid']);
      }).toList();
    });
  }

  void _addStudentToAttendance(String uid, String name) async {
    setState(() {
      selectedStudents.add({'uid': uid, 'stud_name': name});
      availableStudents.removeWhere((student) => student['uid'] == uid);
    });

    await FirebaseFirestore.instance
        .collection('vehicle')
        .doc(widget.parkingSpace.id)
        .update({
      'selectedStudentUIDs': FieldValue.arrayUnion([uid]),
      'timeSeats.$uid': {
        'seatId': uid,
        'isPresent': false,
        'bookedBy': null,
        'stud_name': name,
      },
    });
  }

  void _sendNotification(String message) async {
    if (userRole == 'Admin') {
      for (Map<String, String> student in selectedStudents) {
        String studentId = student['uid']!;
        await FirebaseFirestore.instance
            .collection('users')
            .doc(studentId)
            .collection('notifications')
            .add({
          'message': message,
          'timestamp': FieldValue.serverTimestamp(),
        });

        // Send a text message to the student's device
        await FirebaseFirestore.instance.collection('messages').add({
          'senderId': _user?.uid,
          'receiverId': studentId,
          'message': message,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification sent to selected students')),
      );
    }
  }

  void _showMessageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Message'),
        content: TextField(
          controller: _messageController,
          decoration: const InputDecoration(hintText: 'Enter your message'),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          TextButton(
            child: const Text('Send'),
            onPressed: () {
              Navigator.pop(context);
              _sendNotification(_messageController.text);
              _messageController.clear();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book a Seat at ${widget.parkingSpace.busNumber}'),
        actions: [
          if (userRole == 'Admin')
            IconButton(
              icon: Icon(Icons.notifications),
              onPressed: _showMessageDialog,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('vehicle')
              .doc(widget.parkingSpace.id)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final data = snapshot.data!.data() as Map<String, dynamic>?;
            if (data == null) {
              return const Center(child: Text('No data available.'));
            }
            List<Map<String, dynamic>> students = [];
            for (int i = 0; i < data['totalSeats']; i++) {
              final seatKey = 'seat_$i';
              final studentData = data['timeSeats'][seatKey] as Map<String, dynamic>?;
              students.add({
                'uid': seatKey,
                'stud_name': studentData != null && studentData.containsKey('stud_name')
                    ? studentData['stud_name']
                    : 'empty stud ${i + 1}',
                'isPresent': studentData != null && studentData.containsKey('isPresent')
                    ? studentData['isPresent']
                    : false,
              });
            }

            int totalSeats = data['totalSeats'] ?? 0;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16.0,
                      mainAxisSpacing: 16.0,
                      childAspectRatio: 2,
                    ),
                    itemCount: totalSeats,
                    itemBuilder: (context, index) {
                      final student = students[index];
                      return Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(10),
                        child: InkWell(
                          onTap: userRole == 'Admin'
                              ? () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          BookingConfirmationScreen(
                                        seatAttendance: widget.parkingSpace,
                                        studentId: student['uid'],
                                        studentName: student['stud_name'],
                                        isPresent: student['isPresent'],
                                      ),
                                    ),
                                  );
                                }
                              : null,
                          child: Container(
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              color: student['isPresent']
                                  ? Colors.green
                                  : Colors.grey,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  student['stud_name'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  student['isPresent'] ? 'Present' : 'Absent',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
