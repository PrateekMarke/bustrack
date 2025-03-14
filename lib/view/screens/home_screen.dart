
// import 'package:bustrack/controller/firebase_controller.dart';
// import 'package:bustrack/model/seat_arrengement_model.dart';
// import 'package:bustrack/view/auth/auth_controller.dart';
// import 'package:bustrack/view/auth/student_login_screen.dart';
// import 'package:bustrack/view/screens/add_bus.dart';
// import 'package:bustrack/view/screens/attendance_screen.dart';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:location/location.dart';

// class HomeScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final authController = Provider.of<AuthController>(context);
//     final userRole = authController.role ?? '';
//     final firebaseService = FirebaseController();

//     if (userRole == 'Admin') {
//       _shareAdminLocation();
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Available Buses'),
//         actions: [
//           if (userRole == 'Admin')
//             IconButton(
//               icon: Icon(Icons.add),
//               onPressed: () {
//                 Navigator.push(context,
//                     MaterialPageRoute(builder: (_) => AddBusSpacePage()));
//               },
//             ),
//         ],
//       ),
//       body: StreamBuilder<List<SeatingArrengement>>(
//         stream: firebaseService.getvehicleNumber(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (snapshot.hasError) {
//             return Center(child: Text('Error loading data: ${snapshot.error}'));
//           }
//           if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(child: Text('No buses available.'));
//           }
//           final vehicle = snapshot.data!;
//           return ListView.builder(
//             itemCount: vehicle.length,
//             itemBuilder: (context, index) {
//               final space = vehicle[index];
//               return ListTile(
//                 title: Text("${space.driverName} (${space.busNumber})"),
//                 subtitle: StreamBuilder<DocumentSnapshot>(
//                   stream: FirebaseFirestore.instance
//                       .collection('vehicle')
//                       .doc(space.id)
//                       .snapshots(),
//                   builder: (context, snapshot) {
//                     if (!snapshot.hasData) {
//                       return const Text('Loading...');
//                     }
//                     final data = snapshot.data!.data() as Map<String, dynamic>;
//                     final totalStudents =
//                         (data['selectedStudentUIDs'] as List).length;
//                     return Text('Total Students: $totalStudents');
//                   },
//                 ),
//                 trailing: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     IconButton(
//                       icon: Icon(Icons.location_on),
//                       onPressed: () {
                       
//                       },
//                     ),
//                     if (userRole == 'Admin')
//                       IconButton(
//                         icon: Icon(Icons.delete),
//                         onPressed: () async {
//                           // Show a confirmation dialog before deleting
//                           bool confirmDelete = await showDialog(
//                             context: context,
//                             builder: (context) => AlertDialog(
//                               title: const Text('Delete Bus'),
//                               content: const Text(
//                                   'Are you sure you want to delete this bus?'),
//                               actions: [
//                                 TextButton(
//                                   child: const Text('Cancel'),
//                                   onPressed: () {
//                                     Navigator.pop(context, false);
//                                   },
//                                 ),
//                                 TextButton(
//                                   child: const Text('Delete'),
//                                   onPressed: () {
//                                     Navigator.pop(context, true);
//                                   },
//                                 ),
//                               ],
//                             ),
//                           );

//                           if (confirmDelete) {
//                             await firebaseService.deleteVehicle(space.id);
//                             if (context.mounted) {
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 const SnackBar(
//                                     content: Text('Bus deleted successfully')),
//                               );
//                             }
//                           }
//                         },
//                       ),
//                   ],
//                 ),
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => BookingScreen(parkingSpace: space),
//                     ),
//                   );
//                 },
//               );
//             },
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           authController.signOut(context).then((_) {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (context) => StudentLoginScreen()),
//             );
//           });
//         },
//         child: Icon(Icons.exit_to_app),
//       ),
//     );
//   }

//   void _shareAdminLocation() async {
//     Location location = new Location();

//     bool _serviceEnabled;
//     PermissionStatus _permissionGranted;
//     LocationData _locationData;

//     _serviceEnabled = await location.serviceEnabled();
//     if (!_serviceEnabled) {
//       _serviceEnabled = await location.requestService();
//       if (!_serviceEnabled) {
//         return;
//       }
//     }

//     _permissionGranted = await location.hasPermission();
//     if (_permissionGranted == PermissionStatus.denied) {
//       _permissionGranted = await location.requestPermission();
//       if (_permissionGranted != PermissionStatus.granted) {
//         return;
//       }
//     }

//     _locationData = await location.getLocation();

//     FirebaseFirestore.instance
//         .collection('admin_location')
//         .doc('location')
//         .set({
//       'latitude': _locationData.latitude,
//       'longitude': _locationData.longitude,
//     });

//     location.onLocationChanged.listen((LocationData currentLocation) {
//       FirebaseFirestore.instance
//           .collection('admin_location')
//           .doc('location')
//           .update({
//         'latitude': currentLocation.latitude,
//         'longitude': currentLocation.longitude,
//       });
//     });
//   }
// }
