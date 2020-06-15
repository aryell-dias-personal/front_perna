import 'dart:convert';
import 'package:simple_rsa/simple_rsa.dart';

class RsaDecoder{
  String rsaPublicKey;
  String rsaPrivateKey;
  final encoder = JsonEncoder();
  final decoder = JsonDecoder();
  
  RsaDecoder({
    this.rsaPublicKey,
    this.rsaPrivateKey
  });

  Future<String> encode(body) async {
    String toBeEncoded = encoder.convert(body);
    String encodedBody = await encryptString(toBeEncoded, rsaPublicKey);
    return encodedBody;
  }

  Future<dynamic> decode(toBeDecoded) async {
    dynamic decodedBody = await decryptString(toBeDecoded, rsaPrivateKey);
    dynamic body = decoder.convert(decodedBody);
    return body;
  }
}