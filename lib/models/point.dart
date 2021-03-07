import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:perna/helpers/decoder.dart';

class Point {
  Point({this.local, this.time});

  factory Point.fromJson(Map<String, dynamic> parsedJson){
    return Point(
      local: decodeLatLng(parsedJson['local'] as String),
      time: DateTime.fromMillisecondsSinceEpoch(
        (parsedJson['time'] as int)*1000)
    );
  }

  LatLng local;
  DateTime time;

  dynamic toJson() => <String, dynamic>{
    'email': local.toString(),
    'time': time.millisecondsSinceEpoch/1000
  };
}