import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:perna/helpers/appLocalizations.dart';
import 'package:perna/helpers/creditCard.dart';
import 'package:perna/models/creditCard.dart';

class CreditCardForm extends StatefulWidget {
  const CreditCardForm({
    Key key,
    this.onSubmit,
    this.cardNumber,
    this.expiryDate,
    this.cardHolderName,
    this.cvvCode,
    this.obscureCvv = false,
    this.obscureNumber = false,
    @required this.isAmex,
    @required this.formKey,
    @required this.onCreditCardChange
  }) : super(key: key);

  final Function() onSubmit;
  final bool isAmex;
  final String cardNumber;
  final String expiryDate;
  final String cardHolderName;
  final String cvvCode;
  final void Function(CreditCard) onCreditCardChange;
  final bool obscureCvv;
  final bool obscureNumber;
  final GlobalKey<FormState> formKey;

  @override
  _CreditCardFormState createState() => _CreditCardFormState();
}

class _CreditCardFormState extends State<CreditCardForm> {
  String cardNumber;
  String expiryDate;
  String cardHolderName;
  String cvvCode;
  bool isCvvFocused = false;

  void Function(CreditCard) onCreditCardChange;
  CreditCard creditCardModel;

  final MaskedTextController _cardNumberController =
      MaskedTextController(mask: '0000 0000 0000 0000');
  final TextEditingController _expiryDateController =
      MaskedTextController(mask: '00/00');
  final TextEditingController _cardHolderNameController =
      TextEditingController();
  final TextEditingController _cvvCodeController =
      MaskedTextController(mask: '0000');

  FocusNode cvvFocusNode = FocusNode();
  FocusNode cardNumberNode = FocusNode();
  FocusNode expiryDateNode = FocusNode();
  FocusNode cardHolderNode = FocusNode();

  void textFieldFocusDidChange() {
    creditCardModel.isCvvFocused = cvvFocusNode.hasFocus;
    onCreditCardChange(creditCardModel);
  }

  void createCreditCard() {
    cardNumber = widget.cardNumber ?? '';
    expiryDate = widget.expiryDate ?? '';
    cardHolderName = widget.cardHolderName ?? '';
    cvvCode = widget.cvvCode ?? '';

    creditCardModel = CreditCard(
      cardNumber: cardNumber, 
      expiryDate: expiryDate, 
      cardHolderName: cardHolderName, 
      cvvCode: cvvCode, 
      isCvvFocused: isCvvFocused
    );
  }

  @override
  void initState() {
    super.initState();

    createCreditCard();

    onCreditCardChange = widget.onCreditCardChange;

    cvvFocusNode.addListener(textFieldFocusDidChange);

    _cardNumberController.addListener(() {
      setState(() {
        cardNumber = _cardNumberController.text;
        creditCardModel.cardNumber = cardNumber;
        onCreditCardChange(creditCardModel);
      });
    });

    _expiryDateController.addListener(() {
      setState(() {
        expiryDate = _expiryDateController.text;
        creditCardModel.expiryDate = expiryDate;
        onCreditCardChange(creditCardModel);
      });
    });

    _cardHolderNameController.addListener(() {
      setState(() {
        cardHolderName = _cardHolderNameController.text;
        creditCardModel.cardHolderName = cardHolderName;
        onCreditCardChange(creditCardModel);
      });
    });

    _cvvCodeController.addListener(() {
      setState(() {
        cvvCode = _cvvCodeController.text;
        creditCardModel.cvvCode = cvvCode;
        onCreditCardChange(creditCardModel);
      });
    });
  }

  @override
  void dispose() {
    cardHolderNode.dispose();
    cvvFocusNode.dispose();
    expiryDateNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            margin: const EdgeInsets.only(left: 16, top: 0, right: 16),
            child: TextFormField(
              obscureText: widget.obscureNumber,
              controller: _cardNumberController,
              onEditingComplete: () {
                FocusScope.of(context).requestFocus(expiryDateNode);
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: AppLocalizations.of(context).translate("creditCardNumber"),
                hintText: 'XXXX XXXX XXXX XXXX',
              ),
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              validator: (String value) {
                if (value.isEmpty || value.length < 16) {
                  return AppLocalizations.of(context).translate("cardNumberError");
                }
                return null;
              },
            ),
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  margin: const EdgeInsets.only(left: 16, top: 6, right: 5),
                  child: TextFormField(
                    controller: _expiryDateController,
                    focusNode: expiryDateNode,
                    onEditingComplete: () {
                      FocusScope.of(context).requestFocus(cvvFocusNode);
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: AppLocalizations.of(context).translate("creditCardExpireDate"),
                      hintText: 'XX/XX',
                    ),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    validator: (String value) {
                      if (value.isEmpty) {
                        return AppLocalizations.of(context).translate("cardDateError");
                      }

                      final DateTime now = DateTime.now();
                      final List<String> date = value.split(RegExp(r'/'));
                      final int month = int.parse(date.first);
                      final int year = int.parse('20${date.last}');
                      final DateTime cardDate = DateTime(year, month);

                      if (cardDate.isBefore(now) || month > 12 || month == 0) {
                        return AppLocalizations.of(context).translate("cardDateError");
                      }
                      return null;
                    },
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  margin: const EdgeInsets.only(left: 5, top: 6, right: 16),
                  child: TextFormField(
                    obscureText: widget.obscureCvv,
                    focusNode: cvvFocusNode,
                    controller: _cvvCodeController,
                    onEditingComplete: () {
                      FocusScope.of(context).requestFocus(cardHolderNode);
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: AppLocalizations.of(context).translate("cvv"),
                      hintText: widget.isAmex ? 'XXXX' : 'XXX' ,
                    ),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    onChanged: (String text) {
                      setState(() {
                        cvvCode = text;
                      });
                    },
                    validator: (value) {
                      if (value.isEmpty || value.length != (widget.isAmex ? 4 : 3)) {
                        return AppLocalizations.of(context).translate("cvvError");
                      }
                      return null;
                    },
                  ),
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            margin: const EdgeInsets.only(left: 16, top: 6, right: 16),
            child: TextFormField(
              controller: _cardHolderNameController,
              focusNode: cardHolderNode,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: AppLocalizations.of(context).translate("cardHolder"),
              ),
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.done,
              onEditingComplete: () {
                onCreditCardChange(creditCardModel);
              },
              onFieldSubmitted: (_) => widget.onSubmit(),
              validator: (value) {
                if (value.isEmpty) {
                  return AppLocalizations.of(context).translate("cardHolderError");
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }
}