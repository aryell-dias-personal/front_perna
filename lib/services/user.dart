import 'dart:convert';

import 'package:perna/constants/constants.dart';
import 'package:http/http.dart';
import 'package:perna/models/askedPoint.dart';

class UserService {
  final encoder = JsonEncoder();
  Future<int> postNewAskedPoint(AskedPoint askedPoint) async {
    Response res = await post("${baseUrl}insertAskedPoint", body:  encoder.convert(askedPoint.toJson()));
    return res.statusCode;
  }
}