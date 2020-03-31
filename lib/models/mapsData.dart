import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapsData{
  List<LatLng> route;
  LatLng nextPlace;

  MapsData({this.nextPlace, this.route});

  factory MapsData.fromJson(Map<String, dynamic> parsedJson){
    
    List<dynamic> nextPlace = parsedJson["nextPlace"];
    LatLng nextPlaceLatLng = nextPlace != null ? 
      LatLng(nextPlace.first, nextPlace.last) : null;
    return MapsData(
      nextPlace: nextPlaceLatLng,
      route: parsedJson["route"].map<LatLng>((coords){
        return coords != null ? LatLng(coords.first, coords.last) : null;
      }).toList()
    );
  }
}
