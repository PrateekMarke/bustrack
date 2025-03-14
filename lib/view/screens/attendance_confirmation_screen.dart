
// import 'package:bustrack/model/seat_arrengement_model.dart';
// import 'package:flutter/material.dart';
// import '../../controller/firebase_controller.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class BookingConfirmationScreen extends StatefulWidget {
//   final SeatingArrengement seatAttendance;
//   final String studentId;
//   final String studentName;
//   final bool isPresent;

//   const BookingConfirmationScreen({
//     required this.seatAttendance,
//     required this.studentId,
//     required this.studentName,
//     required this.isPresent,
//   });

//   @override
//   _BookingConfirmationScreenState createState() =>
//       _BookingConfirmationScreenState();
// }

// class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
//   final FirebaseController _firebaseService = FirebaseController();
//   User? _user = FirebaseAuth.instance.currentUser;
//   TextEditingController _nameController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _nameController.text = widget.studentName;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Attendance Confirmation'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Attendance Details',
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 20),
//             Text('Bus Number: ${widget.seatAttendance.busNumber}'),
//             const SizedBox(height: 10),
//             TextField(
//               controller: _nameController,
//               decoration: const InputDecoration(labelText: 'Student Name'),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _updateStudentName,
//               child: const Text('Set Name'),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 if (widget.isPresent) {
//                   _markAsAbsent();
//                 } else {
//                   _markAsPresent();
//                 }
//               },
//               child: Text(widget.isPresent ? 'Absent' : 'Present'),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.popUntil(context, (route) => route.isFirst);
//               },
//               child: const Text('Back to Home'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<void> _updateStudentName() async {
//     // Update the student's name in Firestore
//     await FirebaseFirestore.instance
//         .collection('vehicle')
//         .doc(widget.seatAttendance.id)
//         .update({
//       'timeSeats.${widget.studentId}.stud_name': _nameController.text,
//     });

//     // Show a confirmation message
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Student name updated')),
//     );
//   }

//   Future<void> _markAsPresent() async {
//     // Update the student's attendance status in Firestore
//     await FirebaseFirestore.instance
//         .collection('vehicle')
//         .doc(widget.seatAttendance.id)
//         .update({
//       'timeSeats.${widget.studentId}.isPresent': true,
//       'timeSeats.${widget.studentId}.stud_name': _nameController.text,
//     });

//     // Send a notification to the student
//     await FirebaseFirestore.instance
//         .collection('users')
//         .doc(widget.studentId)
//         .collection('notifications')
//         .add({
//       'message': 'You have been marked as present.',
//       'timestamp': FieldValue.serverTimestamp(),
//     });

//     // Send a text message to the student's device
//     await FirebaseFirestore.instance.collection('messages').add({
//       'senderId': _user?.uid,
//       'receiverId': widget.studentId,
//       'message': 'You have been marked as present.',
//       'timestamp': FieldValue.serverTimestamp(),
//     });

//     // Show a confirmation message
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Student marked as present')),
//     );

//     // Navigate back to the previous screen
//     Navigator.pop(context);
//   }

//   Future<void> _markAsAbsent() async {
//     // Update the student's attendance status in Firestore
//     await FirebaseFirestore.instance
//         .collection('vehicle')
//         .doc(widget.seatAttendance.id)
//         .update({
//       'timeSeats.${widget.studentId}.isPresent': false,
//       'timeSeats.${widget.studentId}.stud_name': _nameController.text,
//     });

//     // Send a notification to the student
//     await FirebaseFirestore.instance
//         .collection('users')
//         .doc(widget.studentId)
//         .collection('notifications')
//         .add({
//       'message': 'You have been marked as absent.',
//       'timestamp': FieldValue.serverTimestamp(),
//     });

//     // Send a text message to the student's device
//     await FirebaseFirestore.instance.collection('messages').add({
//       'senderId': _user?.uid,
//       'receiverId': widget.studentId,
//       'message': 'You have been marked as absent.',
//       'timestamp': FieldValue.serverTimestamp(),
//     });

//     // Show a confirmation message
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Student marked as absent')),
//     );

//     // Navigate back to the previous screen
//     Navigator.pop(context);
//   }
// }
