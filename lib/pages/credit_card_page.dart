import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:perna/helpers/app_localizations.dart';
import 'package:perna/helpers/credit_card.dart';
import 'package:perna/helpers/show_snack_bar.dart';
import 'package:perna/main.dart';
import 'package:perna/models/credit_card.dart';
import 'package:perna/services/payments.dart';
import 'package:perna/widgets/form/credit_card_form.dart';
import 'package:perna/widgets/button/add_button.dart';
import 'package:perna/widgets/credit_card/credit_card_widget.dart';

class CreditCardPage extends StatefulWidget {
  const CreditCardPage({@required this.userToken});

  final String userToken;

  @override
  State<StatefulWidget> createState() => CreditCardPageState();
}

class CreditCardPageState extends State<CreditCardPage> {
  bool isLoading = false;
  bool isAmex = false;
  Widget cardType = const SizedBox(
    height: 48,
    width: 48,
  );
  CreditCard creditCardModel = CreditCard();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Future<void> _onPressed(BuildContext context) async {
    if (formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });
      final int statusCode = await getIt<PaymentsService>()
          .addCard(creditCardModel, widget.userToken);
      if (statusCode == 200) {
        Navigator.popUntil(context, (Route<dynamic> route) => route.isFirst);
        showSnackBar(
            AppLocalizations.of(context).translate('successfully_added_card'),
            Colors.greenAccent,
            context);
      } else {
        setState(() {
          cardType = const SizedBox(
            height: 48,
            width: 48,
          );
          creditCardModel = CreditCard();
          isLoading = false;
        });
        showSnackBar(
            AppLocalizations.of(context).translate('unsuccessfully_added_card'),
            Colors.redAccent,
            context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Theme.of(context).brightness,
        centerTitle: true,
        title: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
          RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: TextStyle(
                    color: Theme.of(context).textTheme.bodyText2.color,
                    fontFamily: 'ProductSans'),
                children: <TextSpan>[
                  TextSpan(
                      text:
                          AppLocalizations.of(context).translate('credit_card'),
                      style: const TextStyle(
                          fontSize: 30, fontWeight: FontWeight.bold)),
                ],
              ),
              maxLines: 2),
          const SizedBox(width: 5),
          const Icon(Icons.credit_card, size: 30),
        ]),
        backgroundColor: Theme.of(context).backgroundColor,
        iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
        textTheme: TextTheme(
            headline6: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 20,
                fontFamily: Theme.of(context).textTheme.headline6.fontFamily)),
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      resizeToAvoidBottomInset: true,
      body: Builder(
        builder: (BuildContext context) => isLoading
            ? Center(
                child: SpinKitDoubleBounce(
                    size: 100.0, color: Theme.of(context).primaryColor))
            : SafeArea(
                child: Column(
                children: <Widget>[
                  CreditCardWidget(
                      isAmex: isAmex,
                      cardType: cardType,
                      cardNumber: creditCardModel.cardNumber ?? '',
                      expiryDate: creditCardModel.expiryDate ?? '',
                      cardHolderName: creditCardModel.cardHolderName ?? '',
                      cvvCode: creditCardModel.cvvCode ?? '',
                      showBackView: creditCardModel.isCvvFocused ?? false),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          CreditCardForm(
                            isAmex: isAmex,
                            formKey: formKey,
                            obscureCvv: true,
                            obscureNumber: true,
                            onCreditCardChange: onCreditCardChange,
                            onSubmit: () => _onPressed(context),
                          ),
                          const SizedBox(height: 26),
                          AddButton(
                            onPressed: () => _onPressed(context),
                            readOnly: false,
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              )),
      ),
    );
  }

  void onCreditCardChange(CreditCard newCreditCardModel) {
    setState(() {
      creditCardModel = newCreditCardModel;
      cardType = getCardTypeIcon(newCreditCardModel.cardNumber,
          (bool willBeAmex, String cardBrand) {
        setState(() {
          isAmex = willBeAmex;
          creditCardModel.brand = cardBrand;
        });
      });
    });
  }
}
