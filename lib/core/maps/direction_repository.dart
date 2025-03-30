import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
class Directions {
  final List<LatLng> polylinePoints;
  final String totalDistance;
  final String totalDuration;
  Directions({
    required this.polylinePoints,
    required this.totalDistance,
    required this.totalDuration,
  });
}
class DirectionsRepository {
  static const String _baseUrl = 'https://maps.gomaps.pro/maps/api/directions/json';
  static const String _apiKey = 'AlzaSyxSot2dqQFGPzZHyIENLqTk2OzZ0Q8Q7-h';

  final Dio _dio;

  DirectionsRepository({Dio? dio}) : _dio = dio ?? Dio();

  Future<Directions?> getDirections({
    required LatLng origin,
    required LatLng destination,
  }) async {
    try {
      final response = await _dio.get(
        _baseUrl,
        queryParameters: {
          'origin': '${origin.latitude},${origin.longitude}',
          'destination': '${destination.latitude},${destination.longitude}',
          'key': _apiKey,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final routes = data['routes'];

        if (routes.isNotEmpty) {
          final polylineEncoded = routes[0]['overview_polyline']['points'];
          String distance = '';
          String duration = '';
          if ((routes[0]['legs'] as List).isNotEmpty) {
            final leg = routes[0]['legs'][0];
            distance = leg['distance']['text'];
            duration = leg['duration']['text'];
          }
          PolylinePoints polylinePoints = PolylinePoints();
          List<PointLatLng> result = polylinePoints.decodePolyline(polylineEncoded);
          return Directions(
            polylinePoints: result
                .map((point) => LatLng(point.latitude, point.longitude))
                .toList(),
            totalDistance: distance,
            totalDuration: duration,
          );
        }
      }
    } catch (e) {
      print('Error fetching directions: $e');
    }
    return null;
  }
}
