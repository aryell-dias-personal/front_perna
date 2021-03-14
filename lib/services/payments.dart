import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:http/http.dart';
import 'package:perna/helpers/my_decoder.dart';
import 'package:perna/models/asked_point.dart';
import 'package:stripe_payment/stripe_payment.dart';
import 'package:perna/models/credit_card.dart' as model;

class PaymentsService {
  PaymentsService({required this.myDecoder}) {
    StripePayment.setOptions(StripeOptions(
        publishableKey:
            FlavorConfig.instance.variables['paymentPublishableKey'] as String,
        merchantId: FlavorConfig.instance.variables['merchantId'] as String,
        androidPayMode:
            FlavorConfig.instance.variables['androidPayMode'] as String));
  }

  MyDecoder myDecoder;
  String baseUrl = FlavorConfig.instance.variables['baseUrl'] as String;

  Future<List<model.CreditCard>> listCard(String token) async {
    final Response res = await post(Uri.parse('$baseUrl/listCreditCard'),
        body: await myDecoder.encode(<String, dynamic>{}),
        headers: <String, String>{'Authorization': token});
    if (res.statusCode == 200) {
      final dynamic response = await myDecoder.decode(res.body);
      return response['retrivedCards']
          .map<model.CreditCard>((dynamic parsedJson) =>
              model.CreditCard.fromJson(parsedJson as Map<String, dynamic>))
          .toList() as List<model.CreditCard>;
    }
    return <model.CreditCard>[];
  }

  Future<int> confirmAskedPointPayment(
      AskedPoint askedPoint, String token) async {
    final dynamic body = await myDecoder.encode(askedPoint.toJson());
    final Response res = await post(
        Uri.parse('$baseUrl/confirmAskedPointPayment'),
        body: body,
        headers: <String, String>{'Authorization': token});
    if (res.statusCode == 200) {
      final dynamic response = await myDecoder.decode(res.body);
      if (response['paid'] as bool) {
        return res.statusCode;
      }
    }
    return 500;
  }

  Future<int> deleteCard(String creditCardId, String token) async {
    final dynamic body =
        await myDecoder.encode(<String, String>{'creditCardId': creditCardId});
    final Response res = await post(Uri.parse('$baseUrl/deleteCreditCard'),
        body: body, headers: <String, String>{'Authorization': token});
    if (res.statusCode == 200) {
      final dynamic response = await myDecoder.decode(res.body);
      if (response['deleted'] as bool) {
        return res.statusCode;
      }
    }
    return 500;
  }

  Future<int> turnCardDefault(String creditCardId, String token) async {
    final dynamic body =
        await myDecoder.encode(<String, String>{'creditCardId': creditCardId});
    final Response res = await post(Uri.parse('$baseUrl/turnDefaultCreditCard'),
        body: body, headers: <String, String>{'Authorization': token});
    return res.statusCode;
  }

  Future<int> addCard(model.CreditCard creditCard, String token) async {
    try {
      final String cardNumber = creditCard.cardNumber.replaceAll(' ', '');
      final List<String> expSlices = creditCard.expiryDate.split('/');
      final int expMonth = int.parse(expSlices.first);
      final int expYear = int.parse('20${expSlices.last}');
      final Token tokenWithCard = await StripePayment.createTokenWithCard(
          CreditCard(
              number: cardNumber,
              cvc: creditCard.cvvCode,
              name: creditCard.cardHolderName,
              expYear: expYear,
              expMonth: expMonth,
              last4: cardNumber.substring(12),
              brand: creditCard.brand));
      final Response res = await post(Uri.parse('$baseUrl/insertCreditCard'),
          body: await myDecoder
              .encode(<String, String>{'source': tokenWithCard.tokenId}),
          headers: <String, String>{'Authorization': token});
      return res.statusCode;
    } catch (err) {
      return 500;
    }
  }
}
