import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:http/http.dart';
import 'package:perna/helpers/my_decoder.dart';
import 'package:perna/models/askedPoint.dart';

class UserService {
  MyDecoder myDecoder;
  String baseUrl = FlavorConfig.instance.variables['baseUrl'];
  
  UserService({
    this.myDecoder
  });

  Future<AskedPoint> simulateAskedPoint(AskedPoint askedPoint, String token) async {
    Response res = await post(
      Uri.parse('${baseUrl}simulateAskedPoint'),
      body: await myDecoder.encode(askedPoint.toJson()),
      headers: {
        'Authorization': token
      }
    );
    if(res.statusCode == 200) {
      dynamic response = await myDecoder.decode(res.body);
      return AskedPoint.fromJson(response['simulatedAskedPoint']);
    }
    return null;
  }
}