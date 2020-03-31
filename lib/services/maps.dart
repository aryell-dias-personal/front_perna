import 'dart:convert';
import 'package:perna/constants/constants.dart';
import 'package:http/http.dart';
import 'package:perna/models/mapsData.dart';

class MapsService {
  final encoder = JsonEncoder();
  final decoder = JsonDecoder();

  Future<MapsData> getMapsData(String email) async {
    final body = encoder.convert({'email': email, 'currentTime': DateTime.now().millisecondsSinceEpoch/60000});
    Response response = await post("${baseUrl}getMapsData", body: body);
    if(response.statusCode != 200)
      return null;
    return MapsData.fromJson(decoder.convert(response.body));
  }
}