import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class StaticMapService{
  final JsonDecoder decoder = const JsonDecoder();
  final String baseUrl = 'https://maps.googleapis.com/maps/api/directions/';
  String apiKey = FlavorConfig.instance.variables['apiKey'] as String;

  String mountStaticMapUrl({
    List<LatLng> route,
    LatLng markerA, LatLng markerB 
  }){
    const String baseUrl = 'https://maps.googleapis.com/maps/api/staticmap';
    String routeParams = '';
    if(route != null && route.isNotEmpty) {
      routeParams = '&path=color:0x0000ff|weight:5';
      for (final LatLng point in route) {
        routeParams += '|${point.latitude},${point.longitude}';
      }
    }
    String markersParams = '';
    if(markerA != null) {
      markersParams += '&markers=color:blue%7Clabel:A%7C${markerA.latitude},${markerA.longitude}';
    }
    if(markerB != null) {
      markersParams += '&markers=color:red%7Clabel:B%7C${markerB.latitude},${markerB.longitude}';
    }
    return '$baseUrl?size=600x300$routeParams$markersParams&key=$apiKey';
  }

  Future<Uint8List> getUint8List({
    List<LatLng> route,
    LatLng markerA, LatLng markerB 
  }) async {
    final String url = mountStaticMapUrl(markerA: markerA, markerB: markerB, route: route);
    final Response response = await get(Uri.parse(url));   
    return Uint8List.fromList(response.bodyBytes);
  }

}