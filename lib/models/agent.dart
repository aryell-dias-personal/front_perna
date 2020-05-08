import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:perna/helpers/decoder.dart';
import 'package:perna/models/point.dart';

class Agent {
  LatLng garage;
  LatLng position;
  String friendlyGarage;
  List<Point> route;
  int places;
  DateTime askedEndAt;
  DateTime askedStartAt;
  String name;
  String email;
  String fromEmail;
  List<String> askedPointIds;
  List<String> watchedBy;
  bool old;

  Agent({
    this.garage, 
    this.position, 
    this.friendlyGarage, 
    this.places, 
    this.name, 
    this.route, 
    this.askedStartAt, 
    this.askedEndAt, 
    this.email,
    this.fromEmail,
    this.old=false,
    this.askedPointIds,
    this.watchedBy=const[]
  });
  
  factory Agent.fromJson(Map<String, dynamic> parsedJson){
    if(parsedJson == null)
      return null;
    return Agent(
      garage: decodeLatLng(parsedJson['garage']),
      old: parsedJson['old'],
      position: parsedJson['position']!=null? decodeLatLng(parsedJson['position']): null,
      places: parsedJson['places'],
      friendlyGarage: parsedJson['friendlyGarage'],
      name: parsedJson['name'],
      route: parsedJson['route']?.map<Point>((point)=>Point.fromJson(point))?.toList(),
      askedStartAt: DateTime.fromMillisecondsSinceEpoch(parsedJson['askedStartAt'].round()*1000),
      askedEndAt: DateTime.fromMillisecondsSinceEpoch(parsedJson['askedEndAt'].round()*1000),
      email: parsedJson['email'],
      fromEmail: parsedJson['fromEmail'],
      watchedBy: parsedJson["watchedBy"]!=null?parsedJson["watchedBy"].map<String>((email)=>"$email").toList():null,
      askedPointIds: parsedJson["askedPointIds"]!=null?parsedJson["askedPointIds"].map<String>((id)=>"$id").toList():null
    );
  }

  Agent copyWith({garage, friendlyGarage, places, name, route, askedStartAt, askedEndAt, email, fromEmail, askedPointIds, position}) => Agent(
    garage: garage ?? this.garage,
    position: position ?? this.position,
    friendlyGarage: friendlyGarage ?? this.friendlyGarage,
    places: places ?? this.places,
    name: name ?? this.name,
    route: route ?? this.route,
    askedStartAt: askedStartAt ?? this.askedStartAt,
    askedEndAt: askedEndAt ?? this.askedEndAt,
    email: email ?? this.email,
    fromEmail: fromEmail ?? this.fromEmail,
    askedPointIds: askedPointIds ?? this.askedPointIds,
    watchedBy: watchedBy ?? this.watchedBy,
    old: old ?? this.old
  );

  dynamic toJson() => {
    "garage": "${garage.latitude}, ${garage.longitude}",
    "position": position!=null?"${position.latitude}, ${position.longitude}":null,
    "places": places,
    "friendlyGarage": friendlyGarage,
    "name": name,
    "route": route != null ? route.map<String>((Point point)=>point.toJson()).toList(): null,
    "askedStartAt": askedStartAt.millisecondsSinceEpoch/1000,
    "askedEndAt": askedEndAt.millisecondsSinceEpoch/1000,
    "email": email,
    "fromEmail": fromEmail,
    "askedPointIds": askedPointIds,
    "watchedBy": watchedBy,
    "old": old
  };
}