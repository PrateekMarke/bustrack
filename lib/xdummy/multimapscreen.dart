import 'package:bustrack/view/screens/location.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';

class Mapscreen extends StatefulWidget {
  const Mapscreen({super.key});

  @override
  State<Mapscreen> createState() => _MapscreenState();
}

class _MapscreenState extends State<Mapscreen> {
  final MapController _mapController = MapController();
  LatLng? _selectedLocation; // ✅ Store selected location
  final LocationService _locationService = LocationService();

  @override
  void initState() {
    super.initState();
    _locationService.initializeLocation((LatLng location) {
      setState(() {
        _selectedLocation = location;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select Location'), backgroundColor: Colors.blue, centerTitle: true),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedLocation ?? LatLng(20.5937, 78.9629), // Default to India
              initialZoom: 05,
              onTap: (tapPosition, LatLng point) {
                setState(() {
                  _selectedLocation = point; // ✅ Save selected location
                });
              },
            ),
            children: [
              TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
              CurrentLocationLayer(style: LocationMarkerStyle(markerSize: Size(35, 35))),

              // ✅ Marker for the selected location
              if (_selectedLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedLocation!,
                      width: 40,
                      height: 40,
                      child: Icon(Icons.location_pin, color: Colors.red, size: 40),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_selectedLocation != null) {
            Navigator.pop(context, _selectedLocation); // ✅ Return selected location
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Please select a location!")),
            );
          }
        },
        backgroundColor: Colors.blue,
        child: Icon(Icons.check, size: 30, color: Colors.white),
      ),
    );
  }
}
