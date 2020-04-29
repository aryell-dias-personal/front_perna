import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:perna/helpers/decoder.dart';
import 'package:perna/models/point.dart';

class Agent {
  LatLng garage;
  String friendlyGarage;
  List<Point> route;
  int places;
  DateTime askedEndAt;
  DateTime askedStartAt;
  String name;
  String email;
  String fromEmail;
  List<String> askedPointIds;

  Agent({
    this.garage, 
    this.friendlyGarage, 
    this.places, 
    this.name, 
    this.route, 
    this.askedStartAt, 
    this.askedEndAt, 
    this.email,
    this.fromEmail,
    this.askedPointIds
  });
  
  static bool invalidArgs(LatLng garage, String friendlyGarage, int places, String name, DateTime askedStartAt, DateTime askedEndAt, String email){
    return email == null || email == "" || garage == null || places == 0
      || name == null || name == "" || friendlyGarage == null || friendlyGarage == "" 
      || askedStartAt == null || askedEndAt == null;
  }

  factory Agent.fromJson(Map<String, dynamic> parsedJson){
    if(parsedJson == null)
      return null;
    return Agent(
      garage: decodeLatLng(parsedJson['garage']),
      places: parsedJson['places'],
      friendlyGarage: parsedJson['friendlyGarage'],
      name: parsedJson['name'],
      route: parsedJson['route']?.map<Point>((point)=>Point.fromJson(point))?.toList(),
      askedStartAt: DateTime.fromMillisecondsSinceEpoch(parsedJson['askedStartAt'].round()*1000),
      askedEndAt: DateTime.fromMillisecondsSinceEpoch(parsedJson['askedEndAt'].round()*1000),
      email: parsedJson['email'],
      fromEmail: parsedJson['fromEmail'],
      askedPointIds: parsedJson["askedPointIds"]!=null?parsedJson["askedPointIds"].map<String>((id)=>"$id").toList():null
    );
  }

  dynamic toJson() => {
    "garage": "${garage.latitude}, ${garage.longitude}",
    "places": places,
    "friendlyGarage": friendlyGarage,
    "name": name,
    "route": route != null ? route.map<String>((Point point)=>point.toJson()).toList(): null,
    "askedStartAt": askedStartAt.millisecondsSinceEpoch/1000,
    "askedEndAt": askedEndAt.millisecondsSinceEpoch/1000,
    "email": email,
    "fromEmail": fromEmail,
    "askedPointIds": askedPointIds
  };
}