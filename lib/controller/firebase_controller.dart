

// import 'package:bustrack/model/seat_arrengement_model.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class FirebaseController {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   // Stream for real-time updates of parking spaces
//   Stream<List<SeatingArrengement>> getvehicleNumber() {
//     return _firestore.collection('vehicle').snapshots().map((snapshot) {
//       return snapshot.docs.map((doc) {
//         return SeatingArrengement.fromFirestore(
//             doc.data() as Map<String, dynamic>, doc.id);
//       }).toList();
//     });
//   }

//   // Method for booking a slot
//   Future<void> bookSlot(String spaceId, String slotId) async {
//     User? user = _auth.currentUser;
//     if (user == null) return;

//     await _firestore.collection('vehicle').doc(spaceId).update({
//       'timeSeats.$slotId.isPresent': false,
//       'timeSeats.$slotId.bookedBy': user.uid,
//     });
//   }

//   // Method for canceling a booking
//   Future<void> cancelBooking(String spaceId, String slotId) async {
//     User? user = _auth.currentUser;
//     if (user == null) return;

//     await _firestore.collection('vehicle').doc(spaceId).update({
//       'timeSeats.$slotId.isPresent': true,
//       'timeSeats.$slotId.bookedBy': null,
//     });
//   }

//   Future<void> deleteVehicle(String vehicleId) async {
//     try {
//       await _firestore.collection('vehicle').doc(vehicleId).delete();
//     } catch (e) {
//       print('Error deleting vehicle: $e');
//     }
//   }
// }
