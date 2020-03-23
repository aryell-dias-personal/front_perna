import 'dart:convert';
import 'package:perna/constants/constants.dart';
import 'package:http/http.dart';

class DriverService {
  Future<dynamic> postNewAgent(String garage, int places, double startAt, double endAt, String email) async {
    final encoder = JsonEncoder();
    final body = encoder.convert({
      "agent": { 
        "garage": garage,
        "places": places,
        "startAt": startAt,
        "endAt": endAt
      },
      "email": email
    });
    Response res = await post("${baseUrl}insertAgent", body: body);
    return res.statusCode;
  }
}