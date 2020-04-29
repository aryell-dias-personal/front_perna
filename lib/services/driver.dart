import 'dart:convert';
import 'package:perna/constants/constants.dart';
import 'package:http/http.dart';
import 'package:perna/models/agent.dart';

class DriverService {
  final encoder = JsonEncoder();

  Future<int> postNewAgent(Agent agent) async {
    Response res = await post("${baseUrl}insertAgent", body: encoder.convert(agent.toJson()));
    return res.statusCode;
  }

  Future<int> answerNewAgent(String fromEmail, String toEmail, bool accepted) async {
    final body = encoder.convert({
      "fromEmail": fromEmail,
      "toEmail": toEmail,
      "accepted": accepted
    });
    Response res = await post("${baseUrl}answerNewAgent", body: body);
    return res.statusCode;
  }

  Future<int> askNewAgent(Agent agent) async {
    Response res = await post("${baseUrl}askNewAgent", body: encoder.convert(agent.toJson()));
    return res.statusCode;
  }
}