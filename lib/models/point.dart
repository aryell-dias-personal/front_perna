import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:perna/helpers/decoder.dart';

class Point {
  Point({this.local, this.time});

  factory Point.fromJson(Map<String, dynamic> parsedJson){
    final dynamic time = parsedJson['time'];
    final int timeInt = time is int ? time: (time as double).round();
    return Point(
      local: decodeLatLng(parsedJson['local'] as String),
      time: DateTime.fromMillisecondsSinceEpoch(timeInt*1000)
    );
  }

  LatLng local;
  DateTime time;

  dynamic toJson() => <String, dynamic>{
    'local': '${local.latitude}, ${local.longitude}',
    'time': time.millisecondsSinceEpoch/1000
  };
} 