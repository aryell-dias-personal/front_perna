import 'package:perna/constants/constants.dart';
import 'package:http/http.dart';
import 'package:perna/helpers/rsaDecoder.dart';
import 'package:perna/models/agent.dart';

class DriverService {
  RsaDecoder rsaDecoder;

  DriverService({
    this.rsaDecoder
  });

  Future<int> postNewAgent(Agent agent, String token) async {
    Response res = await post(
      "${baseUrl}insertAgent", 
      body: await rsaDecoder.encode(agent.toJson()),
      headers: {
        'Authorization': token
      }
    );
    return res.statusCode;
  }

  Future<int> answerNewAgent(String fromEmail, String toEmail, bool accepted) async {
    final body = await rsaDecoder.encode({
      "fromEmail": fromEmail,
      "toEmail": toEmail,
      "accepted": accepted
    });
    Response res = await post("${baseUrl}answerNewAgent", body: body);
    return res.statusCode;
  }

  Future<int> askNewAgent(Agent agent) async {
    Response res = await post("${baseUrl}askNewAgent", body: await rsaDecoder.encode(agent.toJson()));
    return res.statusCode;
  }
}