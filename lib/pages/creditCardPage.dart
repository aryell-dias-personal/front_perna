import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:perna/helpers/appLocalizations.dart';
import 'package:perna/helpers/creditCard.dart';
import 'package:perna/models/creditCard.dart';
import 'package:perna/widgets/creditCardForm.dart';
import 'package:perna/widgets/addButton.dart';
import 'package:perna/widgets/creditCardWidget.dart';

class CreditCardPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => CreditCardPageState();
}

class CreditCardPageState extends State<CreditCardPage> {
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  bool isAmex = false;
  Widget cardType = Container(
    height: 48,
    width: 48,
  );
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Theme.of(context).brightness,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,          
          children:<Widget>[
            RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyText2.color, 
                  fontFamily: "ProductSans"
                ),
                children:  <TextSpan>[
                  TextSpan(
                    text: AppLocalizations.of(context).translate("payment"), 
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)
                  ),
                ],
              ) 
              , maxLines: 2
            ),
            SizedBox(width: 5),
            Icon(Icons.credit_card, size: 30),
          ]
        ),
        backgroundColor: Theme.of(context).backgroundColor,
        iconTheme: IconThemeData(
          color: Theme.of(context).primaryColor
        ),
        textTheme: TextTheme(
          headline6: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: 20,
            fontFamily: Theme.of(context).textTheme.headline6.fontFamily
          )
        ),
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            CreditCardWidget(
              isAmex: this.isAmex,
              cardType: this.cardType,
              cardNumber: cardNumber,
              expiryDate: expiryDate,
              cardHolderName: cardHolderName,
              cvvCode: cvvCode,
              showBackView: isCvvFocused
            ),
            SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CreditCardForm(
                      isAmex: this.isAmex,
                      formKey: formKey,
                      obscureCvv: true,
                      obscureNumber: true,
                      onCreditCardChange: onCreditCardChange,
                    ),
                    SizedBox(height: 26),
                    AddButton(
                      onPressed: () {
                        if (formKey.currentState.validate()) {
                          print('valid!');
                        } else {
                          print('invalid!');
                        }
                      },
                      readOnly: false,
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onCreditCardChange(CreditCard creditCardModel) {
    setState(() {
      cardNumber = creditCardModel.cardNumber;
      expiryDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
      cardType = getCardTypeIcon(cardNumber, (willBeAmex) {
        setState(() {
          isAmex = willBeAmex; 
        });
      });
    });
  }
}