import 'package:bustrack/const/color_pallet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminBusTrackingScreen extends StatefulWidget {
  final Map<String, dynamic> busData;

  const AdminBusTrackingScreen({super.key, required this.busData});

  @override
  State<AdminBusTrackingScreen> createState() => _AdminBusTrackingScreenState();
}

class _AdminBusTrackingScreenState extends State<AdminBusTrackingScreen> {
  final MapController _mapController = MapController();
  LatLng? _busLocation;

  @override
  void initState() {
    super.initState();
    _listenToBusLocation();
  }

  /// Listen for real-time bus location
  void _listenToBusLocation() {
    FirebaseFirestore.instance
        .collection("driver_locations")
        .doc(widget.busData["id"])
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        setState(() {
          _busLocation = LatLng(
            snapshot["latitude"],
            snapshot["longitude"],
          );
        });
        print("📡 Live bus location updated: $_busLocation");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Track ${widget.busData["bus_name"]}"),
     backgroundColor: AppColors.appbarColor,),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _busLocation ?? LatLng(19.997454, 73.789803),
          initialZoom: 12,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          ),
          if (_busLocation != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: _busLocation!,
                  width: 40,
                  height: 40,
                  child: const Icon(
                    Icons.directions_bus,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
