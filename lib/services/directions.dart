import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';

class DirectionsService{
  final decoder = JsonDecoder();
  final baseUrl = 'https://maps.googleapis.com/maps/api/directions/';

  Future<List<LatLng>> getRouteBetweenCoordinates(String googleApiKey, List<LatLng> points) async {
    List<LatLng> latLngWayPoints = points.sublist(1,points.length-1);
    String waypoints = latLngWayPoints.fold<String>('',(String acc, LatLng curr){
      String currLocation = '${curr.latitude},${curr.longitude}';
      if(curr == latLngWayPoints.first){
        return '$currLocation';
      }
      return '$acc|$currLocation';
    });
    String url = '${baseUrl}json?origin=${points.first.latitude},${points.first.longitude}&destination=${points.last.latitude},${points.last.longitude}&waypoints=$waypoints&mode=driving&key=$googleApiKey';
    dynamic response = await get(Uri.parse(url));
    if (response?.statusCode == 200) {
      Map<String, dynamic> body = decoder.convert(response.body);
      if(body['status'] == 'REQUEST_DENIED') return <LatLng>[];
      String encoded = body['routes'][0]['overview_polyline']['points'];
      return decodeEncodedPolyline(encoded);
    } else {
      return <LatLng>[];
    }
  }

  List<LatLng> decodeEncodedPolyline(String encoded){
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;
      LatLng p = LatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble());
      poly.add(p);
    }
    return poly;
  }

}