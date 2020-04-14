import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:perna/constants/constants.dart';

LatLng decodeLatLng(String encodedLatLng) {
  if(encodedLatLng != null){
    String importantPart = encodedLatLng.split(encodedNamesSeparetor).first;
    List<double> coords = importantPart.split(',').map<double>((coord)=>double.parse(coord)).toList();
    return LatLng(coords.first, coords.last);
  }
  return null;
}