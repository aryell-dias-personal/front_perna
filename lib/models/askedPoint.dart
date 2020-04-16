import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:perna/helpers/decoder.dart';

class AskedPoint {
  int endAt;
  int startAt;
  LatLng origin;
  LatLng destiny;
  String name;
  String email;
  String friendlyOrigin;
  String friendlyDestiny;
  String friendlyStartAt;
  String friendlyEndAt;

  AskedPoint({
    this.name, 
    this.email, 
    this.origin, 
    this.destiny, 
    this.friendlyOrigin, 
    this.friendlyDestiny, 
    this.friendlyStartAt, 
    this.friendlyEndAt, 
    this.startAt, 
    this.endAt
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
      friendlyStartAt: parsedJson['friendlyStartAt'],
      friendlyEndAt: parsedJson['friendlyEndAt'],
      startAt: parsedJson['startAt'],
      endAt: parsedJson['endAt']
    );
  }

  dynamic toJson() => {
    "name": name,
    "email": email,
    "origin": origin.toString(),
    "destiny": destiny.toString(),
    "friendlyOrigin": friendlyOrigin,
    "friendlyDestiny": friendlyDestiny,
    "friendlyStartAt": friendlyStartAt,
    "friendlyEndAt": friendlyEndAt,
    "startAt": startAt,
    "endAt": endAt
  };
}