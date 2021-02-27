import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class StaticMapService{
  final decoder = JsonDecoder();
  final baseUrl = "https://maps.googleapis.com/maps/api/directions/";
  String apiKey = FlavorConfig.instance.variables['apiKey'];

  String mountStaticMapUrl({
    List<LatLng> route,
    LatLng markerA, LatLng markerB 
  }){
    final baseUrl = "https://maps.googleapis.com/maps/api/staticmap";
    String routeParams = "";
    if(route != null && route.length > 0) {
      routeParams = "&path=color:0x0000ff|weight:5";
      route.forEach((LatLng point) {
        routeParams += "|${point.latitude},${point.longitude}";
      });
    }
    String markersParams = "";
    if(markerA != null) {
      markersParams += "&markers=color:blue%7Clabel:A%7C${markerA.latitude},${markerA.longitude}";
    }
    if(markerB != null) {
      markersParams += "&markers=color:red%7Clabel:B%7C${markerB.latitude},${markerB.longitude}";
    }
    return "$baseUrl?size=600x300$routeParams$markersParams&key=$apiKey";
  }

  Future<Uint8List> getUint8List({
    List<LatLng> route,
    LatLng markerA, LatLng markerB 
  }) async {
    String url = mountStaticMapUrl(markerA: markerA, markerB: markerB, route: route);
    Response response = await get(url);   
    return Uint8List.fromList(response.bodyBytes);
  }

}