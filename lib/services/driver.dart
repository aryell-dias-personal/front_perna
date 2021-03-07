import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:http/http.dart';
import 'package:perna/helpers/my_decoder.dart';
import 'package:perna/models/agent.dart';

class DriverService {
  DriverService({
    this.myDecoder
  });

  MyDecoder myDecoder;
  String baseUrl = FlavorConfig.instance.variables['baseUrl'] as String;

  Future<int> postNewAgent(Agent agent, String token) async {
    final Response res = await post(
      Uri.parse('${baseUrl}insertAgent'), 
      body: await myDecoder.encode(agent.toJson()),
      headers: <String, String>{
        'Authorization': token
      }
    );
    return res.statusCode;
  }

  Future<int> answerNewAgent(
    String fromEmail, 
    String toEmail, 
    {bool accepted}
  ) async {
    final String body = await myDecoder.encode(<String, dynamic>{
      'fromEmail': fromEmail,
      'toEmail': toEmail,
      'accepted': accepted
    });
    final Response res = await post(
      Uri.parse('${baseUrl}answerNewAgent'), 
      body: body
    );
    return res.statusCode;
  }

  Future<int> askNewAgent(Agent agent) async {
    final Response res = await post(
      Uri.parse('${baseUrl}askNewAgent'), 
      body: await myDecoder.encode(agent.toJson())
    );
    return res.statusCode;
  }
}