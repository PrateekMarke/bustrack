import 'package:bustrack/view/screens/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';

class MyMapscreen extends StatefulWidget {
  const MyMapscreen({super.key});

  @override
  State<MyMapscreen> createState() => _MapscreenState();
}

class _MapscreenState extends State<MyMapscreen> {
  final MapController _mapController = MapController();
  LatLng? _currentLocation;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final LocationService _locationService = LocationService();

  @override
  void initState() {
    super.initState();
    _locationService.initializeLocation((LatLng location) {
      setState(() {
        _currentLocation = location;
      });
    });
  }

  // ✅ Store Driver's Location in Firestore
  Future<void> storeDriverLocation(LatLng location) async {
  try {
    User? user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(code: "not-authenticated", message: "User is not authenticated.");
    }
      String uid = user.uid; // Get current driver ID

    await FirebaseFirestore.instance.collection("driver_locations").doc(uid).set({
      "latitude": location.latitude,
      "longitude": location.longitude,
      "timestamp": FieldValue.serverTimestamp(),
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Location updated successfully!")),
      );

      // Use 'mounted' before popping to avoid errors
      if (mounted) {
        Navigator.pop(context, location);
      }
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Map'), backgroundColor: Colors.blue, centerTitle: true),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentLocation ?? LatLng(20.5937, 78.9629),
              initialZoom: 05,
            ),
            children: [
              TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
              CurrentLocationLayer(style: LocationMarkerStyle(markerSize: Size(35, 35))),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          LatLng? location = await _locationService.getUserLocation(_mapController, context);
          if (location != null) {
            setState(() {
              _currentLocation = location;
            });
            await storeDriverLocation(location);
          }
        },
        backgroundColor: Colors.blue,
        child: Icon(Icons.my_location, size: 30, color: Colors.white),
      ),
    );
  }
}
