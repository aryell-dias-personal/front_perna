import 'dart:convert';
import 'dart:typed_data';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:perna/helpers/decoder.dart';

// TODO: talvez trocar de AskedPoint para AskedPoints ou AskedRoute (inclusive no backend)
class AskedPoint {
  DateTime date;
  List<DateTime> queue;
  List<DateTime> history;
  Duration askedEndAt;
  Duration askedStartAt;
  LatLng origin;
  LatLng destiny;
  String email;
  String friendlyOrigin;
  String friendlyDestiny;
  DateTime actualStartAt;
  DateTime actualEndAt;
  String agentId;
  Uint8List staticMap;

  AskedPoint({
    this.date,
    this.queue,
    this.history,
    this.email, 
    this.origin, 
    this.destiny,
    this.friendlyOrigin, 
    this.friendlyDestiny, 
    this.askedStartAt, 
    this.askedEndAt,
    this.actualStartAt,
    this.actualEndAt,
    this.agentId,
    this.staticMap
  });


  factory AskedPoint.fromJson(Map<String, dynamic> parsedJson){
    
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
    return AskedPoint(
      email: parsedJson['email'],
      origin: decodeLatLng(parsedJson['origin']),
      destiny: decodeLatLng(parsedJson['destiny']),
      friendlyOrigin: parsedJson['friendlyOrigin'],
      friendlyDestiny: parsedJson['friendlyDestiny'],
      date: parseDate(parsedJson['date']),
      askedStartAt: parseDuration(parsedJson['askedStartAt']),
      askedEndAt: parseDuration(parsedJson['askedEndAt']),
      queue: parsedJson['queue']?.map<DateTime>(parseDate)?.toList(),
      history: parsedJson['history']?.map<DateTime>(parseDate)?.toList(),
      actualStartAt: parseDate(parsedJson['actualStartAt']),
      actualEndAt: parseDate(parsedJson['actualEndAt']),
      agentId: parsedJson ['agentId'],
      staticMap: parsedJson['staticMap'] != null ? base64Decode(parsedJson['staticMap']) : null
    );
  }

  AskedPoint copyWith({
    String email, 
    LatLng origin, 
    LatLng destiny, 
    String friendlyOrigin, 
    String friendlyDestiny, 
    Duration askedStartAt, 
    Duration askedEndAt, 
    DateTime date, 
    List<DateTime> queue, 
    List<DateTime> history, 
    DateTime actualStartAt, 
    DateTime actualEndAt, 
    String agentId,
    Uint8List staticMap
  }) => AskedPoint(
    email: email ?? this.email,
    origin: origin ?? this.origin,
    destiny: destiny ?? this.destiny,
    friendlyOrigin: friendlyOrigin ?? this.friendlyOrigin,
    friendlyDestiny: friendlyDestiny ?? this.friendlyDestiny,
    date: date ?? this.date,
    queue: queue ?? this.queue,
    history: history ?? this.history,
    askedStartAt: askedStartAt ?? this.askedStartAt,
    askedEndAt: askedEndAt ?? this.askedEndAt,
    actualStartAt: actualStartAt ?? this.actualStartAt,
    actualEndAt: actualEndAt ?? this.actualEndAt,
    agentId: agentId ?? this.agentId,
    staticMap: staticMap ?? this.staticMap
  );

  dynamic toJson() => {
    "email": email,
    "origin": "${origin.latitude}, ${origin.longitude}",
    "destiny": "${destiny.latitude}, ${destiny.longitude}",
    "friendlyOrigin": friendlyOrigin,
    "friendlyDestiny": friendlyDestiny,
    "queue": queue?.map<double>((date)=>(date.millisecondsSinceEpoch/1000))?.toList(),
    "history": history?.map<double>((date)=>(date.millisecondsSinceEpoch/1000))?.toList(),
    "date": date != null ? date.millisecondsSinceEpoch/1000 : null,
    "askedStartAt": askedStartAt != null ? askedStartAt.inSeconds : null,
    "askedEndAt": askedEndAt != null ? askedEndAt.inSeconds : null,
    "actualStartAt": actualStartAt != null ? actualStartAt.millisecondsSinceEpoch/1000: null,
    "actualEndAt": actualStartAt != null ? actualEndAt.millisecondsSinceEpoch/1000: null,
    "agentId": agentId,
    "staticMap": staticMap != null ? base64Encode(staticMap) : null
  };
}