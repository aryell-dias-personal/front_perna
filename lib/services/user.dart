import 'dart:convert';
import 'package:perna/constants/constants.dart';
import 'package:http/http.dart';

class UserService {
  Future<dynamic> postNewAskedPoint(String origin, String destiny, int startAt, int endAt) async {
    final encoder = JsonEncoder();
    final body = encoder.convert({
      "origin": origin,
      "destiny": destiny,
      "startAt": startAt,
      "endAt": endAt
    });
    Response res = await post("${baseUrl}insertAskedPoint", body: body);
    return res.statusCode;
  }
}