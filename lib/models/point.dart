import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:perna/helpers/decoder.dart';

class Point {
  LatLng local;
  DateTime time;
  Point({this.local, this.time});

  factory Point.fromJson(Map<String, dynamic> parsedJson){
    return Point(
      local: decodeLatLng(parsedJson['local']),
      time: DateTime.fromMillisecondsSinceEpoch(parsedJson['time'].round()*1000)
    );
  }

  dynamic toJson() => {
    'email': local.toString(),
    'time': time.millisecondsSinceEpoch/1000
  };
}