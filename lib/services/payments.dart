import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:http/http.dart';
import 'package:perna/helpers/myDecoder.dart';
import 'package:stripe_payment/stripe_payment.dart';
import 'package:perna/models/creditCard.dart' as model;

class PaymentsService{
  MyDecoder myDecoder;
  String baseUrl = FlavorConfig.instance.variables['baseUrl'];
  
  PaymentsService({
    this.myDecoder
  }) {
    StripePayment.setOptions(
      StripeOptions(
        publishableKey: FlavorConfig.instance.variables['paymentPublishableKey'],
        merchantId: FlavorConfig.instance.variables['merchantId'], 
        androidPayMode: FlavorConfig.instance.variables['androidPayMode']
      )
    );
  }

  Future<List<model.CreditCard>> listCard(String token) async { 
    Response res = await post(
      "${baseUrl}listCreditCard",
      body: await myDecoder.encode({}),
      headers: {
        'Authorization': token
      }
    );
    if(res.statusCode == 200) {
      dynamic response = await myDecoder.decode(res.body);
      return response['retrivedCards'].map<model.CreditCard>(
        (parsedJson) => model.CreditCard.fromJson(parsedJson)
      ).toList();
    }
    return <model.CreditCard>[];
  }

  Future<int> addCard(model.CreditCard creditCard, String token) async { 
    try {
      String cardNumber = creditCard.cardNumber.replaceAll(" ", "");
      List<String> expSlices = creditCard.expiryDate.split('/');
      int expMonth = int.parse(expSlices.first);
      int expYear = int.parse('20${expSlices.last}');
      Token tokenWithCard = await StripePayment.createTokenWithCard(CreditCard(
        number: cardNumber,
        cvc: creditCard.cvvCode,
        name: creditCard.cardHolderName,
        expYear: expYear,
        expMonth: expMonth,
        last4: cardNumber.substring(12),
        brand: creditCard.brand
      ));
      Response res = await post(
        "${baseUrl}insertCreditCard", 
        body: await myDecoder.encode({
          'source': tokenWithCard.tokenId
        }),
        headers: {
          'Authorization': token
        }
      );
      return res.statusCode;
    } catch(err){
      return 500;
    }
  }
}