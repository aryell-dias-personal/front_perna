import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:http/http.dart';
import 'package:perna/helpers/my_decoder.dart';
import 'package:perna/models/asked_point.dart';

class UserService {
  UserService({this.myDecoder});

  MyDecoder myDecoder;
  String baseUrl = FlavorConfig.instance.variables['baseUrl'] as String;

  Future<AskedPoint> simulateAskedPoint(
      AskedPoint askedPoint, String token) async {
    final Response res = await post(Uri.parse('${baseUrl}simulateAskedPoint'),
        body: await myDecoder.encode(askedPoint.toJson()),
        headers: <String, String>{'Authorization': token});
    if (res.statusCode == 200) {
      final dynamic response = await myDecoder.decode(res.body);
      return AskedPoint.fromJson(
          response['simulatedAskedPoint'] as Map<String, dynamic>);
    }
    return null;
  }
}
