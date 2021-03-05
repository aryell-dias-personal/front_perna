import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:http/http.dart';
import 'package:perna/helpers/myDecoder.dart';
import 'package:perna/models/agent.dart';

class DriverService {
  MyDecoder myDecoder;
  String baseUrl = FlavorConfig.instance.variables['baseUrl'];

  DriverService({
    this.myDecoder
  });

  Future<int> postNewAgent(Agent agent, String token) async {
    Response res = await post(
      Uri(path: "${baseUrl}insertAgent"), 
      body: await myDecoder.encode(agent.toJson()),
      headers: {
        'Authorization': token
      }
    );
    return res.statusCode;
  }

  Future<int> answerNewAgent(String fromEmail, String toEmail, bool accepted) async {
    final body = await myDecoder.encode({
      "fromEmail": fromEmail,
      "toEmail": toEmail,
      "accepted": accepted
    });
    Response res = await post(Uri(path: "${baseUrl}answerNewAgent"), body: body);
    return res.statusCode;
  }

  Future<int> askNewAgent(Agent agent) async {
    Response res = await post(Uri(path: "${baseUrl}askNewAgent"), body: await myDecoder.encode(agent.toJson()));
    return res.statusCode;
  }
}