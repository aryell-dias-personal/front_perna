import 'dart:convert';
import 'package:perna/constants/constants.dart';
import 'package:http/http.dart';

class UserService {
  Future<dynamic> postNewAskedPoint(String name, String origin, String destiny, double startAt, double endAt, String email) async {
    final encoder = JsonEncoder();
    final body = encoder.convert({
      "askedPoint":{
        "origin": origin,
        "destiny": destiny,
        "name": name,
        "startAt": startAt,
        "endAt": endAt
      },
      "email": email
    });
    Response res = await post("${baseUrl}insertAskedPoint", body: body);
    return res.statusCode;
  }
}