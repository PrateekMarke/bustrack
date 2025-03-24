import 'package:bustrack/xdummy/maps/direction_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class TrackingMapScreen extends StatefulWidget {
  final Map<String, dynamic> selectedBus;

  const TrackingMapScreen({super.key, required this.selectedBus});

  @override
  State<TrackingMapScreen> createState() => _TrackingMapScreenState();
}

class _TrackingMapScreenState extends State<TrackingMapScreen> {
  final MapController _mapController = MapController();
    final FirebaseAuth _auth = FirebaseAuth.instance;
  LatLng? _studentLocation;
  LatLng? _busLocation;
  List<LatLng> _polylinePoints = [];
  String _distance = "";
  String _duration = "";
   

  final DirectionsRepository _directionsRepository = DirectionsRepository();

  @override
  void initState() {
    super.initState();
    _getStudentLocation();
    _listenToBusLocation();
  }

  // Fetch Student's Current Location
Future<void> _getStudentLocation() async {
  User? user = _auth.currentUser;
  final studentDoc = await FirebaseFirestore.instance
      .collection("students") // ✅ Correct collection
      .doc(user?.uid) // Replace with the actual student UID
      .get();

  if (studentDoc.exists) {
    setState(() {
      _studentLocation = LatLng(
        studentDoc["latitude"],
        studentDoc["longitude"],
      );
    });
    print("✅ Student location fetched: $_studentLocation");
    _updateRoute(); // Update route after fetching location
  } else {
    print("❌ No student document found for ID: student_uid");
  }
}



  // Listen to Real-time Bus Location Updates
  void _listenToBusLocation() {
    FirebaseFirestore.instance
        .collection("driver_locations")
        .doc(widget.selectedBus["id"]) // Driver ID as document ID
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        setState(() {
          _busLocation = LatLng(
            snapshot["latitude"],
            snapshot["longitude"],
          );
        });
        print("✅ Bus location updated: $_busLocation");
        _updateRoute();
      }
    });
  }

  // Fetch Route (Polyline, Distance, Duration)
  Future<void> _updateRoute() async {
    if (_studentLocation == null || _busLocation == null) {
      print("⚠️ Skipping route update: Locations not available");
      return;
    }

    print("🔵 Fetching route...");

final DirectionsRepository _directionsRepository = DirectionsRepository();

final Directions? directions = await _directionsRepository.getDirections(
  origin: _busLocation!,
  destination: _studentLocation!,
);



    if (directions != null) {
      setState(() {
        _polylinePoints = directions.polylinePoints;
        _distance = directions.totalDistance;
        _duration = directions.totalDuration;
      });

      print("✅ Route updated: Distance=$_distance, Duration=$_duration");
    } else {
      print("❌ Failed to fetch route.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bus Tracking")),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _studentLocation ?? LatLng(19.997454, 73.789803),
              initialZoom: 12,
            ),
            children: [
              TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
              CurrentLocationLayer(style: LocationMarkerStyle(markerSize: const Size(35, 35))),

              // ✅ Student Marker
              // if (_studentLocation != null)
              //   MarkerLayer(
              //     markers: [
              //       Marker(
              //         point: _studentLocation!,
              //         width: 40,
              //         height: 40,
              //         child: const Icon(Icons.person_pin_circle, color: Colors.blue, size: 40),
              //       ),
              //     ],
              //   ),

              // ✅ Bus Marker
              if (_busLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _busLocation!,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.directions_bus, color: Colors.red, size: 40),
                    ),
                  ],
                ),

              // ✅ Polyline between student and bus
              if (_polylinePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _polylinePoints,
                      color: Colors.green,
                      strokeWidth: 5,
                    ),
                  ],
                ),
            ],
          ),

          // ✅ Show Distance & Duration as Overlay
          if (_distance.isNotEmpty && _duration.isNotEmpty)
           Positioned(
  top: 10,
  left: 10,
  right: 10,
  child: Card(
    color: Colors.white.withOpacity(0.8),
    elevation: 5,
    child: Padding(
      padding: const EdgeInsets.all(10),
      child: SingleChildScrollView(  // ✅ Prevent overflow
        scrollDirection: Axis.horizontal,  
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("🛣 Distance: $_distance",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
            SizedBox(width: 10), // ✅ Add spacing
            Text("⏳ Duration: $_duration",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
          ],
        ),
      ),
    ),
  ),
)

        ],
      ),
    );
  }
}
