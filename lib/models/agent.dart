import 'dart:convert';
import 'dart:typed_data';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:perna/helpers/decoder.dart';
import 'package:perna/models/point.dart';

class Agent {
  Agent(
      {this.garage,
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
      this.companyId,
      this.fromEmail,
      this.old = false,
      this.askedPointIds,
      this.watchedBy = const <String>[],
      this.region,
      this.staticMap});

  factory Agent.fromJson(Map<String, dynamic> parsedJson) {
    DateTime parseDate(dynamic value) {
      if (value == null) return null;
      final int valueInt = value is int ? value : (value as double).round();
      return DateTime.fromMillisecondsSinceEpoch(valueInt * 1000);
    }

    Duration parseDuration(dynamic value) {
      if (value == null) return null;
      final int valueInt = value is int ? value : (value as double).round();
      return Duration(seconds: valueInt);
    }

    Uint8List decode64(dynamic staticMap) {
      if (staticMap == null) return null;
      return base64Decode(staticMap as String);
    }

    if (parsedJson == null) {
      return null;
    }

    return Agent(
        garage: decodeLatLng(parsedJson['garage'] as String),
        old: parsedJson['old'] as bool,
        position: parsedJson['position'] != null
            ? decodeLatLng(parsedJson['position'] as String)
            : null,
        places: parsedJson['places'] as int,
        friendlyGarage: parsedJson['friendlyGarage'] as String,
        route: parsedJson['route']
            ?.map<Point>((dynamic point) =>
                Point.fromJson(point as Map<String, dynamic>))
            ?.toList() as List<Point>,
        date: parseDate(parsedJson['date']),
        askedStartAt: parseDuration(parsedJson['askedStartAt']),
        askedEndAt: parseDuration(parsedJson['askedEndAt']),
        queue: parsedJson['queue']?.map<DateTime>(parseDate)?.toList()
            as List<DateTime>,
        history: parsedJson['history']?.map<DateTime>(parseDate)?.toList()
            as List<DateTime>,
        email: parsedJson['email'] as String,
        companyId: parsedJson['companyId'] as String,
        fromEmail: parsedJson['fromEmail'] as String,
        watchedBy: parsedJson['watchedBy']
            ?.map<String>((dynamic email) => '$email')
            ?.toList() as List<String>,
        region: parsedJson['region']
            ?.map<String>((dynamic region) => '$region')
            ?.toList() as List<String>,
        askedPointIds: parsedJson['askedPointIds']
            ?.map<String>((dynamic id) => '$id')
            ?.toList() as List<String>,
        staticMap: decode64(parsedJson['staticMap']));
  }

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
  String companyId;
  String fromEmail;
  List<String> askedPointIds;
  List<String> watchedBy;
  List<String> region;
  bool old;
  Uint8List staticMap;

  Agent copyWith(
          {LatLng garage,
          String friendlyGarage,
          int places,
          DateTime date,
          List<DateTime> queue,
          List<DateTime> history,
          List<Point> route,
          Duration askedStartAt,
          Duration askedEndAt,
          String email,
          String companyId,
          String fromEmail,
          List<String> askedPointIds,
          LatLng position,
          List<String> watchedBy,
          List<String> region,
          bool old,
          Uint8List staticMap}) =>
      Agent(
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
          companyId: companyId ?? this.companyId,
          fromEmail: fromEmail ?? this.fromEmail,
          askedPointIds: askedPointIds ?? this.askedPointIds,
          watchedBy: watchedBy ?? this.watchedBy,
          region: region ?? this.region,
          old: old ?? this.old,
          staticMap: staticMap ?? this.staticMap);

  dynamic toJson() => <String, dynamic>{
        'garage': '${garage.latitude}, ${garage.longitude}',
        'position': position != null
            ? '${position.latitude}, ${position.longitude}'
            : null,
        'places': places,
        'friendlyGarage': friendlyGarage,
        'route': route?.map<dynamic>((Point point) => point.toJson())?.toList(),
        'queue': queue
            ?.map<double>((DateTime date) => date.millisecondsSinceEpoch / 1000)
            ?.toList(),
        'history': history
            ?.map<double>((DateTime date) => date.millisecondsSinceEpoch / 1000)
            ?.toList(),
        'date': date != null ? date.millisecondsSinceEpoch / 1000 : null,
        'askedStartAt': askedStartAt?.inSeconds,
        'askedEndAt': askedEndAt?.inSeconds,
        'email': email,
        'companyId': companyId,
        'fromEmail': fromEmail,
        'askedPointIds': askedPointIds,
        'watchedBy': watchedBy,
        'region': region,
        'old': old,
        'staticMap': staticMap != null ? base64Encode(staticMap) : null
      };
}
