import 'dart:convert';

class MyDecoder{
  final encoder = JsonEncoder();
  final decoder = JsonDecoder();

  Future<String> encode(body) async {
    String toBeEncoded = encoder.convert(body);
    return toBeEncoded;
  }

  Future<dynamic> decode(toBeDecoded) async {
    String decodedBody = toBeDecoded;
    dynamic body = decoder.convert(decodedBody);
    return body;
  }
}