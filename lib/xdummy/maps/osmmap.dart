import 'package:bustrack/xdummy/maps/direction_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:dio/dio.dart';


class OSMMapScreen extends StatefulWidget {
  @override
  _OSMMapScreenState createState() => _OSMMapScreenState();
}

class _OSMMapScreenState extends State<OSMMapScreen> {
  final MapController _mapController = MapController();
  final DirectionsRepository _directionsRepository = DirectionsRepository(dio: Dio());

  LatLng? _origin;
  LatLng? _destination;
  Directions? _info;

  List<LatLng> _polylineCoordinates = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OpenStreetMap with Directions'),
        actions: [
          if (_origin != null)
            TextButton(
              onPressed: () => _mapController.move(_origin!, 15.0),
              style: TextButton.styleFrom(foregroundColor: Colors.green),
              child: const Text('ORIGIN'),
            ),
          if (_destination != null)
            TextButton(
              onPressed: () => _mapController.move(_destination!, 15.0),
              style: TextButton.styleFrom(foregroundColor: Colors.blue),
              child: const Text('DEST'),
            ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(19.997454, 73.789803),
              initialZoom: 13.0,
              onTap: (tapPosition, latLng) => _addMarker(latLng),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
              ),
              if (_origin != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _origin!,
                      width: 40,
                      height: 40,
                      child: Icon(Icons.location_on, color: Colors.green, size: 40),
                    ),
                  ],
                ),
              if (_destination != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _destination!,
                      width: 40,
                      height: 40,
                       child: Icon(Icons.location_on, color: Colors.green, size: 40),
                    ),
                  ],
                ),
              if (_polylineCoordinates.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _polylineCoordinates,
                      strokeWidth: 5.0,
                      color: Colors.red,
                    ),
                  ],
                ),
            ],
          ),
          if (_info != null)
            Positioned(
              top: 20.0,
              left: 20.0,
              right: 20.0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
                decoration: BoxDecoration(
                  color: Colors.yellowAccent,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: const [BoxShadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 6.0)],
                ),
                child: Text(
                  '${_info!.totalDistance}, ${_info!.totalDuration}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
          if (_info != null) {
            _mapController.move(_polylineCoordinates.first, 13.0);
          }
        },
        child: const Icon(Icons.center_focus_strong),
      ),
    );
  }

  void _addMarker(LatLng pos) async {
    if (_origin == null || (_origin != null && _destination != null)) {
      setState(() {
        _origin = pos;
        _destination = null;
        _polylineCoordinates.clear();
        _info = null;
      });
    } else {
      setState(() => _destination = pos);
      final directions = await _directionsRepository.getDirections(origin: _origin!, destination: pos);
      
      if (directions != null) {
        setState(() {
          _info = directions;
          _polylineCoordinates = directions.polylinePoints;
        });
      }
    }
  }
}
