import 'dart:convert';

class MyDecoder{
  final JsonEncoder encoder = const JsonEncoder();
  final JsonDecoder decoder = const JsonDecoder();

  Future<String> encode(dynamic body) async {
    final String toBeEncoded = encoder.convert(body);
    return toBeEncoded;
  }

  Future<dynamic> decode(String toBeDecoded) async {
    final String decodedBody = toBeDecoded;
    final dynamic body = decoder.convert(decodedBody);
    return body;
  }
}