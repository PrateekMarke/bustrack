import 'package:bustrack/xdummy/studentspages/buscard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';

class BusMapScreen extends StatefulWidget {
  const BusMapScreen({super.key});

  @override
  State<BusMapScreen> createState() => _BusMapScreenState();
}

class _BusMapScreenState extends State<BusMapScreen> {
  final MapController _mapController = MapController();
  LatLng? _studentLocation;
  List<Map<String, dynamic>> _buses = []; // List to store bus data

  @override
  void initState() {
    super.initState();
    _fetchBusLocations();
  }

  Future<void> _fetchBusLocations() async {
    FirebaseFirestore.instance.collection('driver').snapshots().listen((snapshot) {
      List<Map<String, dynamic>> buses = snapshot.docs.map((doc) {
        return {
          "id": doc.id,
          "bus_name": doc["bus_name"],
          "driver_name": doc["name"],
          "contact": doc["contact"],
          "seats": doc["seats"],
          "seat_data": doc["seats_data"],
          "latitude": doc["latitude"],
          "longitude": doc["longitude"],
        };
      }).toList();

      setState(() {
        _buses = buses;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Your Bus'), backgroundColor: Colors.blue, centerTitle: true),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _studentLocation ?? LatLng(19.997454, 73.789803), // Default location
              initialZoom: 10,
            ),
            children: [
              TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
              CurrentLocationLayer(style: LocationMarkerStyle(markerSize: const Size(35, 35))),

              // ✅ Bus Markers
              MarkerLayer(
                markers: _buses.map((bus) {
                  return Marker(
                    point: LatLng(bus["latitude"], bus["longitude"]),
                    width: 50,
                    height: 50,
                    child: GestureDetector(
                      onTap: () {
                        _showBusDetails(bus);
                      },
                      child: const Icon(Icons.directions_bus, color: Colors.red, size: 40),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ✅ Show Bus Details
  void _showBusDetails(Map<String, dynamic> bus) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return BusDetailsCard(bus: bus);
      },
    );
  }
}
