import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:loading/loading.dart';
import 'package:perna/helpers/appLocalizations.dart';
import 'package:perna/helpers/creditCard.dart';
import 'package:perna/helpers/showSnackBar.dart';
import 'package:perna/models/creditCard.dart';
import 'package:perna/services/payments.dart';
import 'package:perna/widgets/creditCardForm.dart';
import 'package:perna/widgets/addButton.dart';
import 'package:perna/widgets/creditCardWidget.dart';

class CreditCardPage extends StatefulWidget {
  final PaymentsService paymentsService;
  final String userToken;
  
  CreditCardPage({
    @required this.paymentsService,
    @required this.userToken
  });

  @override
  State<StatefulWidget> createState() => CreditCardPageState();
}

class CreditCardPageState extends State<CreditCardPage> {
  bool isLoading = false;
  bool isAmex = false;
  Widget cardType = Container(
    height: 48,
    width: 48,
  );
  CreditCard creditCardModel = CreditCard();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  void _onPressed(context) async {
    if (formKey.currentState.validate()) {
      setState(() { isLoading = true; });
      int statusCode = await widget.paymentsService.addCard(creditCardModel, widget.userToken);
      if(statusCode == 200) {
        Navigator.popUntil(context, (route) => route.isFirst);
        showSnackBar(AppLocalizations.of(context).translate("successfully_added_card"), 
          Colors.greenAccent, context);
      } else {
        setState(() {
          this.cardType = Container(
            height: 48,
            width: 48,
          );
          creditCardModel = CreditCard();
          isLoading = false;
        });
        showSnackBar(AppLocalizations.of(context).translate("unsuccessfully_added_card"), 
          Colors.redAccent, context);
      }
    }
  }

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
                    text: AppLocalizations.of(context).translate("credit_card"), 
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
      body: Builder(
        builder: (context) => isLoading ? Center(
          child: Loading(
            indicator: BallPulseIndicator(), 
            size: 100.0, color: Theme.of(context).primaryColor
          )
      ) : SafeArea(
        child: Column(
          children: <Widget>[
            CreditCardWidget(
              isAmex: this.isAmex,
              cardType: this.cardType,
              cardNumber: this.creditCardModel.cardNumber ?? '',
              expiryDate: this.creditCardModel.expiryDate ?? '',
              cardHolderName: this.creditCardModel.cardHolderName ?? '',
              cvvCode: this.creditCardModel.cvvCode ?? '',
              showBackView: this.creditCardModel.isCvvFocused ?? false
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
                      onSubmit: () => _onPressed(context),
                    ),
                    SizedBox(height: 26),
                    AddButton(
                        onPressed: () => _onPressed(context),
                        readOnly: false,
                      )
                    ],
                  ),
                ),
              ),
            ],
          )
        ),
      ),
    );
  }

  void onCreditCardChange(CreditCard newCreditCardModel) {
    setState(() {
      this.creditCardModel = newCreditCardModel;
      this.cardType = getCardTypeIcon(newCreditCardModel.cardNumber, (willBeAmex, cardBrand) {
        setState(() {
          isAmex = willBeAmex; 
          this.creditCardModel.brand = cardBrand;
        });
      });
    });
  }
}