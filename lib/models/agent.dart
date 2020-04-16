import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:perna/helpers/decoder.dart';

class Agent {
  LatLng garage;
  List<LatLng> route;
  int places;
  int endAt;
  int startAt;
  String name;
  String email;
  String friendlyGarage;
  String friendlyStartAt;
  String friendlyEndAt;

  Agent({this.garage, this.places, this.name, this.route, this.friendlyGarage, this.friendlyStartAt, this.friendlyEndAt, this.startAt, this.endAt, this.email});
  
  factory Agent.fromJson(Map<String, dynamic> parsedJson){
    if(parsedJson == null)
      return null;
    return Agent(
      garage: decodeLatLng(parsedJson['garage']),
      places: parsedJson['places'],
      name: parsedJson['name'],
      route: parsedJson['route']?.map<LatLng>((encodedLatLng)=>decodeLatLng(encodedLatLng))?.toList(),
      friendlyGarage: parsedJson['friendlyGarage'],
      friendlyStartAt: parsedJson['friendlyStartAt'],
      friendlyEndAt: parsedJson['friendlyEndAt'],
      startAt: parsedJson['startAt'],
      endAt: parsedJson['endAt'],
      email: parsedJson['email']
    );
  }

  dynamic toJson() => {
    "garage": garage.toString(),
    "places": places,
    "name": name,
    "route": route.map<String>((LatLng latLng)=>latLng.toString()).toList(),
    "friendlyGarage": friendlyGarage,
    "friendlyStartAt": friendlyStartAt,
    "friendlyEndAt": friendlyEndAt,
    "startAt": startAt,
    "endAt": endAt,
    "email": email
  };
}