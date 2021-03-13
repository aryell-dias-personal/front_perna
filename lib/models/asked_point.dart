import 'dart:convert';
import 'dart:typed_data';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:perna/helpers/decoder.dart';

class AskedPoint {
  AskedPoint({
    this.date,
    this.email,
    this.origin,
    this.destiny,
    this.friendlyOrigin,
    this.friendlyDestiny,
    this.staticMap,
    this.currency,
    this.amount,
    this.agentId,
    this.queue,
    this.history,
    this.askedStartAt,
    this.askedEndAt,
    this.actualStartAt,
    this.actualEndAt,
    this.region,
  });

  static AskedPoint? fromJson(Map<String, dynamic>? parsedJson) {
    DateTime? parseDate(dynamic? value) {
      if (value == null) return null;
      final int valueInt = value is int ? value : (value as double).round();
      return DateTime.fromMillisecondsSinceEpoch(valueInt * 1000);
    }

    Duration? parseDuration(dynamic? value) {
      if (value == null) return null;
      final int valueInt = value is int ? value : (value as double).round();
      return Duration(seconds: valueInt);
    }

    Uint8List decode64(dynamic staticMap) {
      return base64Decode(staticMap as String);
    }

    if (parsedJson == null) {
      return null;
    }

    return AskedPoint(
        email: parsedJson['email'] as String,
        currency: parsedJson['currency'] as String,
        amount: parsedJson['amount'] as int,
        origin: decodeLatLng(parsedJson['origin'] as String),
        destiny: decodeLatLng(parsedJson['destiny'] as String),
        friendlyOrigin: parsedJson['friendlyOrigin'] as String,
        friendlyDestiny: parsedJson['friendlyDestiny'] as String,
        date: parseDate(parsedJson['date']),
        askedStartAt: parseDuration(parsedJson['askedStartAt']),
        askedEndAt: parseDuration(parsedJson['askedEndAt']),
        queue: parsedJson['queue']
            ?.map<DateTime>((dynamic date) => parseDate(date)!)
            ?.toList() as List<DateTime>?,
        history: parsedJson['history']
            ?.map<DateTime>((dynamic date) => parseDate(date)!)
            ?.toList() as List<DateTime>?,
        actualStartAt: parseDate(parsedJson['actualStartAt']),
        actualEndAt: parseDate(parsedJson['actualEndAt']),
        region: parsedJson['region']
            ?.map<String>((dynamic region) => '$region')
            ?.toList() as List<String>,
        agentId: parsedJson['agentId'] != null
            ? parsedJson['agentId'] as String
            : null,
        staticMap: decode64(parsedJson['staticMap']));
  }

  AskedPoint copyWith(
          {String? email,
          LatLng? origin,
          LatLng? destiny,
          String? friendlyOrigin,
          String? friendlyDestiny,
          Duration? askedStartAt,
          Duration? askedEndAt,
          DateTime? date,
          List<DateTime>? queue,
          List<DateTime>? history,
          DateTime? actualStartAt,
          DateTime? actualEndAt,
          String? agentId,
          List<String>? region,
          Uint8List? staticMap,
          String? currency,
          int? amount}) =>
      AskedPoint(
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
          region: region ?? this.region,
          currency: currency ?? this.currency,
          amount: amount ?? this.amount,
          staticMap: staticMap ?? this.staticMap);

  DateTime? date;
  LatLng? origin;
  LatLng? destiny;
  String? email;
  String? friendlyOrigin;
  String? friendlyDestiny;
  Uint8List? staticMap;
  List<DateTime>? queue;
  List<DateTime>? history;
  Duration? askedEndAt;
  Duration? askedStartAt;
  String? currency;
  int? amount;
  DateTime? actualStartAt;
  DateTime? actualEndAt;
  String? agentId;
  List<String>? region;

  dynamic toJson() => <String, dynamic>{
        'email': email,
        'origin': '${origin!.latitude}, ${origin!.longitude}',
        'destiny': '${destiny!.latitude}, ${destiny!.longitude}',
        'friendlyOrigin': friendlyOrigin,
        'friendlyDestiny': friendlyDestiny,
        'queue': queue
            ?.map<double>((DateTime date) => date.millisecondsSinceEpoch / 1000)
            .toList(),
        'history': history
            ?.map<double>((DateTime date) => date.millisecondsSinceEpoch / 1000)
            .toList(),
        'date': date!.millisecondsSinceEpoch / 1000,
        'askedStartAt': askedStartAt?.inSeconds,
        'askedEndAt': askedEndAt?.inSeconds,
        'actualStartAt': actualStartAt != null
            ? actualStartAt!.millisecondsSinceEpoch / 1000
            : null,
        'actualEndAt': actualStartAt != null
            ? actualEndAt!.millisecondsSinceEpoch / 1000
            : null,
        'agentId': agentId,
        'region': region,
        'currency': currency,
        'amount': amount,
        'staticMap': staticMap != null ? base64Encode(staticMap!) : null
      };
}
