import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class TrackingMapScreen extends StatefulWidget {
  final Map<String, dynamic> selectedBus;

  const TrackingMapScreen({super.key, required this.selectedBus});

  @override
  State<TrackingMapScreen> createState() => _TrackingMapScreenState();
}

class _TrackingMapScreenState extends State<TrackingMapScreen> {
  final MapController _mapController = MapController();
  LatLng? _studentLocation;
  LatLng? _busLocation;
  List<LatLng> _polylinePoints = [];

  @override
  void initState() {
    super.initState();
    _getStudentLocation();
    _listenToBusLocation();
  }

  // Fetch Student's Current Location
  Future<void> _getStudentLocation() async {
    final studentDoc = await FirebaseFirestore.instance
        .collection("student_location")
        .doc("student_uid") // Replace with actual student UID
        .get();

    if (studentDoc.exists) {
      setState(() {
        _studentLocation = LatLng(
          studentDoc["latitude"],
          studentDoc["longitude"],
        );
      });
      _updatePolyline();
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
        _updatePolyline();
      }
    });
  }

  // Fetch Polyline from API
  Future<void> _updatePolyline() async {
    if (_studentLocation == null || _busLocation == null) return;

    final String apiKey = "AlzaSyxSot2dqQFGPzZHyIENLqTk2OzZ0Q8Q7-h"; // Replace with your API key
    final String url =
        "https://maps.gomaps.pro/maps/api/directions/json?origin=${_studentLocation!.latitude},${_studentLocation!.longitude}&destination=${_busLocation!.latitude},${_busLocation!.longitude}&key=$apiKey";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<LatLng> polylineCoordinates = [];

        if (data["routes"].isNotEmpty) {
          final points = data["routes"][0]["overview_polyline"]["points"];
          polylineCoordinates.addAll(_decodePolyline(points));
        }

        setState(() {
          _polylinePoints = polylineCoordinates;
        });
      }
    } catch (e) {
      print("Error fetching polyline: $e");
    }
  }

  // Decode Polyline Points
  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> polylineCoordinates = [];
    List<int> bytes = encoded.codeUnits;
    int index = 0;
    int lat = 0;
    int lng = 0;

    while (index < bytes.length) {
      int shift = 0;
      int result = 0;
      int byte;

      do {
        byte = bytes[index++] - 63;
        result |= (byte & 0x1F) << shift;
        shift += 5;
      } while (byte >= 0x20);

      int deltaLat = ((result & 1) == 1 ? ~(result >> 1) : (result >> 1));
      lat += deltaLat;

      shift = 0;
      result = 0;

      do {
        byte = bytes[index++] - 63;
        result |= (byte & 0x1F) << shift;
        shift += 5;
      } while (byte >= 0x20);

      int deltaLng = ((result & 1) == 1 ? ~(result >> 1) : (result >> 1));
      lng += deltaLng;

      polylineCoordinates.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return polylineCoordinates;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bus Tracking")),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _studentLocation ?? LatLng(19.997454, 73.789803),
          initialZoom: 12,
        ),
        children: [
          TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
          CurrentLocationLayer(style: LocationMarkerStyle(markerSize: const Size(35, 35))),

          // ✅ Student Marker
          if (_studentLocation != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: _studentLocation!,
                  width: 40,
                  height: 40,
                  child: const Icon(Icons.person_pin_circle, color: Colors.blue, size: 40),
                ),
              ],
            ),

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
    );
  }
}
