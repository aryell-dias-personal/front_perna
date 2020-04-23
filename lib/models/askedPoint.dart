import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:perna/helpers/decoder.dart';

class AskedPoint {
  DateTime askedStartAt;
  DateTime askedEndAt;
  LatLng origin;
  LatLng destiny;
  String name;
  String email;
  String friendlyOrigin;
  String friendlyDestiny;
  DateTime actualStartAt;
  DateTime actualEndAt;
  String agentId;

  AskedPoint({
    this.name, 
    this.email, 
    this.origin, 
    this.destiny,
    this.friendlyOrigin, 
    this.friendlyDestiny, 
    this.askedStartAt, 
    this.askedEndAt,
    this.actualStartAt,
    this.actualEndAt,
    this.agentId
  });

  factory AskedPoint.fromJson(Map<String, dynamic> parsedJson){
    if(parsedJson == null)
      return null;
    return AskedPoint(
      name: parsedJson['name'],
      email: parsedJson['email'],
      origin: decodeLatLng(parsedJson['origin']),
      destiny: decodeLatLng(parsedJson['destiny']),
      friendlyOrigin: parsedJson['friendlyOrigin'],
      friendlyDestiny: parsedJson['friendlyDestiny'],
      askedStartAt: DateTime.fromMillisecondsSinceEpoch(parsedJson['askedStartAt'].round()*1000),
      askedEndAt: DateTime.fromMillisecondsSinceEpoch(parsedJson['askedEndAt'].round()*1000),
      actualStartAt: parsedJson['actualEndAt'] != null ? DateTime.fromMillisecondsSinceEpoch(parsedJson['actualStartAt'].round()*1000) : null,
      actualEndAt: parsedJson['actualEndAt'] != null ? DateTime.fromMillisecondsSinceEpoch(parsedJson['actualEndAt'].round()*1000) : null,
      agentId: parsedJson ['agentId']
    );
  }

  dynamic toJson() => {
    "name": name,
    "email": email,
    "origin": origin.toString(),
    "destiny": destiny.toString(),
    "friendlyOrigin": friendlyOrigin,
    "friendlyDestiny": friendlyDestiny,
    "askedStartAt": askedStartAt.millisecondsSinceEpoch/1000,
    "askedEndAt": askedEndAt.millisecondsSinceEpoch/1000,
    "actualStartAt": actualStartAt != null ? actualStartAt.millisecondsSinceEpoch/1000: null,
    "actualEndAt": actualStartAt != null ? actualEndAt.millisecondsSinceEpoch/1000: null,
    "agentId": agentId
  };
}