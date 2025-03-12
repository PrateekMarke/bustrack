import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddBusSpacePage extends StatefulWidget {
  @override
  _AddBusSpacePageState createState() => _AddBusSpacePageState();
}

class _AddBusSpacePageState extends State<AddBusSpacePage> {
  final _driverName = TextEditingController();
  final _contactNo = TextEditingController();
  final _busesController = TextEditingController();
  final _totalSeatsController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  List<String> selectedStudentUIDs = [];

  Future<void> _addBus() async {
    final driverName = _driverName.text;
    final contactNo = _contactNo.text;
    final busNumber = _busesController.text;
    final totalSeats = int.tryParse(_totalSeatsController.text) ?? 0;

    if (busNumber.isNotEmpty && totalSeats > 0) {
      // Generate a random location within Maharashtra, India
      final random = Random();
      final latitude = 15.6 +
          random.nextDouble() *
              (22.0 - 15.6); // Approximate latitude range for Maharashtra
      final longitude = 72.6 +
          random.nextDouble() *
              (80.9 - 72.6); // Approximate longitude range for Maharashtra

      // Create a map of time Seats
      Map<String, Map<String, dynamic>> timeSeats = {};
      for (int i = 0; i < totalSeats; i++) {
        timeSeats['seat_$i'] = {
          'seatId': 'seat_$i',
          'isPresent': false,
          'bookedBy': null,
          'stud_name': 'empty stud ${i + 1}',
        };
      }

      // Add the Bus to Firestore
      await FirebaseFirestore.instance.collection('vehicle').add({
        'driverName': driverName,
        'contactNo': contactNo,
        'busNumber': busNumber,
        'totalSeats': totalSeats,
        'timeSeats': timeSeats,
        'location': {
          'latitude': latitude,
          'longitude': longitude
        }, // Store the location
        'selectedStudentUIDs': selectedStudentUIDs,
        'emptySeats':
            totalSeats - selectedStudentUIDs.length, // Add empty seats
      });

      // Clear the form fields
      _driverName.clear();
      _contactNo.clear();
      _busesController.clear();
      _totalSeatsController.clear();

      // Show a confirmation message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bus added successfully')),
      );
    } else {
      // Show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid data')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Bus'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _driverName,
                decoration: const InputDecoration(labelText: 'Driver Name'),
              ),
              TextField(
                controller: _contactNo,
                decoration: const InputDecoration(labelText: 'Contact No:'),
              ),
              TextField(
                controller: _busesController,
                decoration: const InputDecoration(labelText: 'Bus Number'),
              ),
              TextField(
                controller: _totalSeatsController,
                decoration: const InputDecoration(labelText: 'Total Seats'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),

              ///Select Button
              // StreamBuilder<QuerySnapshot>(
              //   stream: FirebaseFirestore.instance
              //       .collection('users')
              //       .where('role', isEqualTo: 'Student')
              //       .snapshots(),
              //   builder: (context, snapshot) {
              //     if (!snapshot.hasData) {
              //       return const Center(child: CircularProgressIndicator());
              //     }

              //     List<Map<String, String>> students = snapshot.data!.docs
              //         .map((doc) => {
              //               'uid': doc.id,
              //               'name': doc['name'].toString(),
              //             })
              //         .toList();

              //     return Column(
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: [
              //         ElevatedButton(
              //           onPressed: () async {
              //             List<String>? selected =
              //                 await showDialog<List<String>>(
              //               context: context,
              //               builder: (context) {
              //                 List<String> tempSelected =
              //                     List.from(selectedStudentUIDs);

              //                 return StatefulBuilder(
              //                   builder: (context, setDialogState) {
              //                     return AlertDialog(
              //                       title: const Text("Select Students"),
              //                       content: SingleChildScrollView(
              //                         child: Column(
              //                           children: students.map((student) {
              //                             return CheckboxListTile(
              //                               title: Text(student['name']!),
              //                               value: tempSelected
              //                                   .contains(student['uid']),
              //                               onChanged: (bool? checked) {
              //                                 setDialogState(() {
              //                                   if (checked == true) {
              //                                     tempSelected
              //                                         .add(student['uid']!);
              //                                   } else {
              //                                     tempSelected
              //                                         .remove(student['uid']);
              //                                   }
              //                                 });
              //                               },
              //                             );
              //                           }).toList(),
              //                         ),
              //                       ),
              //                       actions: [
              //                         TextButton(
              //                           onPressed: () {
              //                             Navigator.pop(context,
              //                                 null); // Cancel selection
              //                           },
              //                           child: const Text("Cancel"),
              //                         ),
              //                         TextButton(
              //                           onPressed: () {
              //                             Navigator.pop(context,
              //                                 tempSelected); // Confirm selection
              //                           },
              //                           child: const Text("OK"),
              //                         ),
              //                       ],
              //                     );
              //                   },
              //                 );
              //               },
              //             );

              //             if (selected != null) {
              //               setState(() {
              //                 selectedStudentUIDs = selected;
              //               });
              //             }
              //           },
              //           child: const Text("Select Students"),
              //         ),
              //         const SizedBox(height: 10),
              //         Wrap(
              //           spacing: 8.0,
              //           children: selectedStudentUIDs.map((uid) {
              //             final student = students
              //                 .firstWhere((student) => student['uid'] == uid);
              //             return Chip(
              //               label: Text(student['name']!),
              //               onDeleted: () {
              //                 setState(() {
              //                   selectedStudentUIDs.remove(uid);
              //                 });
              //               },
              //             );
              //           }).toList(),
              //         ),
              //       ],
              //     );

              //   },
              // ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addBus,
                child: const Text('Add Bus'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
