import 'dart:convert';
import 'package:perna/constants/constants.dart';
import 'package:http/http.dart';

class DriverService {
  Future<int> postNewAgent(String name, String garage, String friendlyGarage, int places, DateTime selectedStartDateTime, DateTime selectedEndDateTime, String email) async {
    final encoder = JsonEncoder();
    final body = encoder.convert({
      "agent": { 
        "garage": garage,
        "places": places,
        "name": name,
        "friendlyGarage": friendlyGarage,
        "friendlyStartAt": selectedStartDateTime.toString(),
        "friendlyEndAt": selectedEndDateTime.toString(),
        "startAt": selectedStartDateTime.millisecondsSinceEpoch/60000,
        "endAt": selectedEndDateTime.millisecondsSinceEpoch/60000
      },
      "email": email
    });
    Response res = await post("${baseUrl}insertAgent", body: body);
    return res.statusCode;
  }
}