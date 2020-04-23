import 'dart:convert';
import 'package:perna/constants/constants.dart';
import 'package:http/http.dart';

class DriverService {
  Future<int> postNewAgent(String name, String garage, String friendlyGarage, int places, DateTime selectedStartDateTime, DateTime selectedEndDateTime, String email) async {
    final encoder = JsonEncoder();
    final body = encoder.convert({
      "agent": { 
        "garage": garage,
        "friendlyGarage": friendlyGarage,
        "places": places,
        "name": name,
        "askedStartAt": selectedStartDateTime.millisecondsSinceEpoch/1000,
        "askedEndAt": selectedEndDateTime.millisecondsSinceEpoch/1000
      },
      "email": email
    });
    Response res = await post("${baseUrl}insertAgent", body: body);
    return res.statusCode;
  }
}