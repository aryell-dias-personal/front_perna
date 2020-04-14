import 'dart:convert';
import 'package:perna/constants/constants.dart';
import 'package:http/http.dart';

class UserService {
  final encoder = JsonEncoder();
  final decoder = JsonDecoder();
  
  Future<dynamic> postNewAskedPoint(String name, String origin, String friendlyOrigin, String destiny, String friendlyDestiny, DateTime selectedStartDateTime, DateTime selectedEndDateTime, String email) async {
    final body = this.encoder.convert({
      "askedPoint": {
        "name": name,
        "origin": origin,
        "friendlyOrigin": friendlyOrigin,
        "destiny": destiny,
        "friendlyDestiny": friendlyDestiny,
        "friendlyStartAt": selectedStartDateTime.toString(),
        "friendlyEndAt": selectedEndDateTime.toString(),
        "startAt": selectedStartDateTime.millisecondsSinceEpoch/60000,
        "endAt": selectedEndDateTime.millisecondsSinceEpoch/60000
      },
      "email": email
    });
    Response res = await post("${baseUrl}insertAskedPoint", body: body);
    return res.statusCode;
  }
}