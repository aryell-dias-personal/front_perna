import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';

class DirectionsService {
  final JsonDecoder decoder = const JsonDecoder();
  final String baseUrl = 'https://maps.googleapis.com/maps/api/directions/';

  Future<List<LatLng>> getRouteBetweenCoordinates(
      String googleApiKey, List<LatLng> points) async {
    final List<LatLng> latLngWayPoints = points.sublist(1, points.length - 1);
    final String waypoints =
        latLngWayPoints.fold<String>('', (String acc, LatLng curr) {
      final String currLocation = '${curr.latitude},${curr.longitude}';
      if (curr == latLngWayPoints.first) {
        return currLocation;
      }
      return '$acc|$currLocation';
    });
    final String url =
        '${baseUrl}json?origin=${points.first.latitude},${points.first.longitude}&destination=${points.last.latitude},${points.last.longitude}&waypoints=$waypoints&mode=driving&key=$googleApiKey';
    final dynamic response = await get(Uri.parse(url));
    if (response?.statusCode == 200) {
      final Map<String, dynamic> body =
          decoder.convert(response.body as String) as Map<String, dynamic>;
      if (body['status'] == 'REQUEST_DENIED') return <LatLng>[];
      final String encoded =
          body['routes'][0]['overview_polyline']['points'] as String;
      return decodeEncodedPolyline(encoded);
    } else {
      return <LatLng>[];
    }
  }

  List<LatLng> decodeEncodedPolyline(String encoded) {
    final List<LatLng> poly = <LatLng>[];
    final int len = encoded.length;
    int index = 0;
    int lat = 0, lng = 0;
    void callback(int newIndex) => index = newIndex;
    while (index < len) {
      final int dlat = getComponent(encoded, index, callback: callback);
      lat += dlat;
      final int dlng = getComponent(encoded, index, callback: callback);
      lng += dlng;
      final LatLng p = LatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble());
      poly.add(p);
    }
    return poly;
  }

  int getComponent(String encoded, int initialIndex,
      {void Function(int)? callback}) {
    int b, shift = 0, result = 0;
    int index = initialIndex;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    if (callback != null) {
      callback(index);
    }
    return (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
  }
}
