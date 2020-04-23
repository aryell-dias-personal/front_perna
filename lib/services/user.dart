import 'dart:convert';
import 'package:perna/constants/constants.dart';
import 'package:http/http.dart';

class UserService {
  final encoder = JsonEncoder();
  final decoder = JsonDecoder();
  
  Future<int> postNewAskedPoint(String name, String origin, String friendlyOrigin, String destiny, String friendlyDestiny, DateTime selectedStartDateTime, DateTime selectedEndDateTime, String email) async {
    final body = this.encoder.convert({
      "askedPoint": {
        "name": name,
        "origin": origin,
        "friendlyOrigin": friendlyOrigin,
        "destiny": destiny,
        "friendlyDestiny": friendlyDestiny,
        "askedStartAt": selectedStartDateTime.millisecondsSinceEpoch/1000,
        "askedEndAt": selectedEndDateTime.millisecondsSinceEpoch/1000
      },
      "email": email
    });
    Response res = await post("${baseUrl}insertAskedPoint", body: body);
    return res.statusCode;
  }
}