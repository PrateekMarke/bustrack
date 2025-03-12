import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:flutter/material.dart';

class LocationService {
  final Location _location = Location();

  void initializeLocation(Function(LatLng) onLocationUpdated) {
    _location.onLocationChanged.listen((LocationData locationData) {
      if (locationData.latitude != null && locationData.longitude != null) {
        onLocationUpdated(LatLng(locationData.latitude!, locationData.longitude!));
      }
    });
  }

  Future<LatLng?> getUserLocation(MapController controller, BuildContext context) async {
    LocationData? locationData = await _location.getLocation();
    
    if (locationData.latitude != null && locationData.longitude != null) {
      LatLng userLocation = LatLng(locationData.latitude!, locationData.longitude!);
      controller.move(userLocation, 14);
      return userLocation;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Current location not available.")),
      );
      return null;
    }
  }
}
