import 'dart:convert';
import 'package:perna/constants/constants.dart';
import 'package:http/http.dart';

class DriverService {
  Future<dynamic> postNewAgent(String garage, int places, int startAt, int endAt) async {
    final encoder = JsonEncoder();
    final body = encoder.convert({
      "garage": garage,
      "places": places,
      "startAt": startAt,
      "endAt": endAt
    });
    Response res = await post("${baseUrl}insertAgent", body: body);
    return res.statusCode;
  }
}