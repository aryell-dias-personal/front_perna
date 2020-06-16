import 'package:perna/constants/constants.dart';
import 'package:http/http.dart';
import 'package:perna/helpers/myDecoder.dart';
import 'package:perna/models/askedPoint.dart';

class UserService {
  MyDecoder myDecoder;
  UserService({
    this.myDecoder
  });

  Future<int> postNewAskedPoint(AskedPoint askedPoint, String token) async {
    Response res = await post(
      "${baseUrl}insertAskedPoint", 
      body: await myDecoder.encode(askedPoint.toJson()),
      headers: {
        'Authorization': token
      }
    );
    return res.statusCode;
  }
}