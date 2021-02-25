import 'dart:convert';
import 'dart:typed_data';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:perna/helpers/decoder.dart';
import 'package:perna/models/point.dart';

class Agent {
  LatLng garage;
  LatLng position;
  String friendlyGarage;
  List<Point> route;
  int places;
  DateTime date;
  List<DateTime> queue;
  List<DateTime> history;
  Duration askedEndAt;
  Duration askedStartAt;
  String email;
  String fromEmail;
  List<String> askedPointIds;
  List<String> watchedBy;
  List<String> region;
  bool old;
  Uint8List staticMap;

  Agent({
    this.garage, 
    this.position, 
    this.friendlyGarage, 
    this.places, 
    this.route, 
    this.date,
    this.queue,
    this.history,
    this.askedStartAt, 
    this.askedEndAt, 
    this.email,
    this.fromEmail,
    this.old=false,
    this.askedPointIds,
    this.watchedBy=const[],
    this.region,
    this.staticMap
  });
  
  factory Agent.fromJson(Map<String, dynamic> parsedJson){

    DateTime parseDate(value) {
      if(value == null) return null;
      return DateTime.fromMillisecondsSinceEpoch(value.round()*1000);
    }

    Duration parseDuration(value) {
      if(value == null) return null;
      return Duration(seconds: value.round());
    }

    if(parsedJson == null)
      return null;
    return Agent(
      garage: decodeLatLng(parsedJson['garage']),
      old: parsedJson['old'],
      position: parsedJson['position']!=null? decodeLatLng(parsedJson['position']): null,
      places: parsedJson['places'],
      friendlyGarage: parsedJson['friendlyGarage'],
      route: parsedJson['route']?.map<Point>((point)=>Point.fromJson(point))?.toList(),
      date: parseDate(parsedJson['date']),
      askedStartAt: parseDuration(parsedJson['askedStartAt']),
      askedEndAt: parseDuration(parsedJson['askedEndAt']),
      queue: parsedJson['queue']?.map<DateTime>(parseDate)?.toList(),
      history: parsedJson['history']?.map<DateTime>(parseDate)?.toList(),
      email: parsedJson['email'],
      fromEmail: parsedJson['fromEmail'],
      watchedBy: parsedJson["watchedBy"]!=null?parsedJson["watchedBy"].map<String>((email)=>"$email").toList():null,
      region: parsedJson["region"]!=null?parsedJson["region"].map<String>((region)=>"$region").toList():null,
      askedPointIds: parsedJson["askedPointIds"]!=null?parsedJson["askedPointIds"].map<String>((id)=>"$id").toList():null,
      staticMap: parsedJson['staticMap'] != null ? base64Decode(parsedJson['staticMap']) : null
    );
  }

  Agent copyWith({
    LatLng garage, 
    String friendlyGarage, 
    int places, 
    DateTime date, 
    List<DateTime> queue, 
    List<DateTime> history, 
    List<Point> route, 
    Duration askedStartAt, 
    Duration askedEndAt, 
    String email, 
    String fromEmail, 
    List<String> askedPointIds, 
    LatLng position,
    List<String> watchedBy,
    List<String> region,
    bool old,
    Uint8List staticMap
  }) => Agent(
    garage: garage ?? this.garage,
    position: position ?? this.position,
    friendlyGarage: friendlyGarage ?? this.friendlyGarage,
    places: places ?? this.places,
    route: route ?? this.route,
    date: date ?? this.date,
    queue: queue ?? this.queue,
    history: history ?? this.history,
    askedStartAt: askedStartAt ?? this.askedStartAt,
    askedEndAt: askedEndAt ?? this.askedEndAt,
    email: email ?? this.email,
    fromEmail: fromEmail ?? this.fromEmail,
    askedPointIds: askedPointIds ?? this.askedPointIds,
    watchedBy: watchedBy ?? this.watchedBy,
    region: region ?? this.region,
    old: old ?? this.old,
    staticMap: staticMap ?? this.staticMap
  );

  dynamic toJson() => {
    "garage": "${garage.latitude}, ${garage.longitude}",
    "position": position!=null?"${position.latitude}, ${position.longitude}":null,
    "places": places,
    "friendlyGarage": friendlyGarage,
    "route": route != null ? route.map<String>((Point point)=>point.toJson()).toList(): null,
    "queue": queue?.map<double>((date)=>(date.millisecondsSinceEpoch/1000))?.toList(),
    "history": history?.map<double>((date)=>(date.millisecondsSinceEpoch/1000))?.toList(),
    "date": date != null ? date.millisecondsSinceEpoch/1000 : null,
    "askedStartAt": askedStartAt != null ? askedStartAt.inSeconds : null,
    "askedEndAt": askedEndAt != null ? askedEndAt.inSeconds : null,
    "email": email,
    "fromEmail": fromEmail,
    "askedPointIds": askedPointIds,
    "watchedBy": watchedBy,
    "region": region,
    "old": old,
    "staticMap": staticMap != null ? base64Encode(staticMap) : null
  };
}