import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:perna/constants/constants.dart';

LatLng? decodeLatLng(dynamic? encodedLatLng) {
  if (encodedLatLng is String) {
    final String importantPart =
        encodedLatLng.split(encodedNamesSeparetor).first;
    final List<double> coords = importantPart
        .split(',')
        .map<double>((String coord) => double.parse(coord))
        .toList();
    return LatLng(coords.first, coords.last);
  }
  return null;
}
