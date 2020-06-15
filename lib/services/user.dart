import 'package:perna/constants/constants.dart';
import 'package:http/http.dart';
import 'package:perna/helpers/rsaDecoder.dart';
import 'package:perna/models/askedPoint.dart';

class UserService {
  RsaDecoder rsaDecoder;
  UserService({
    this.rsaDecoder
  });

  Future<int> postNewAskedPoint(AskedPoint askedPoint, String token) async {
    Response res = await post(
      "${baseUrl}insertAskedPoint", 
      body: await rsaDecoder.encode(askedPoint.toJson()),
      headers: {
        'Authorization': token
      }
    );
    return res.statusCode;
  }
}