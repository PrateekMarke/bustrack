import 'package:latlong2/latlong.dart';

class Directions {
  final List<LatLng> polylinePoints;
  final String totalDistance;
  final String totalDuration;

  Directions({
    required this.polylinePoints,
    required this.totalDistance,
    required this.totalDuration,
  });

  factory Directions.fromMap(Map<String, dynamic> map) {
    if (map['routes'] == null || (map['routes'] as List).isEmpty) {
      return Directions(polylinePoints: [], totalDistance: "", totalDuration: "");
    }

    final route = map['routes'][0];

    List<LatLng> points = (route['geometry']['coordinates'] as List)
        .map((coord) => LatLng(coord[1], coord[0]))
        .toList();

    return Directions(
      polylinePoints: points,
      totalDistance: route['summary']['distance'].toString() + ' km',
      totalDuration: route['summary']['duration'].toString() + ' mins',
    );
  }
}
