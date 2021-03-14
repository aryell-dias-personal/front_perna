import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:perna/helpers/app_localizations.dart';
import 'package:perna/helpers/credit_card.dart';
import 'package:perna/models/credit_card.dart';

class CreditCardForm extends StatefulWidget {
  const CreditCardForm(
      {required this.onSubmit,
      required this.isAmex,
      required this.formKey,
      required this.onCreditCardChange,
      this.cardNumber = '',
      this.expiryDate = '',
      this.cardHolderName = '',
      this.cvvCode = '',
      this.obscureCvv = false,
      this.obscureNumber = false});

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
  late String cardNumber;
  late String expiryDate;
  late String cardHolderName;
  late String cvvCode;
  late CreditCard creditCardModel;
  late void Function(CreditCard) onCreditCardChange;

  bool isCvvFocused = false;

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
    cardNumber = widget.cardNumber;
    expiryDate = widget.expiryDate;
    cardHolderName = widget.cardHolderName;
    cvvCode = widget.cvvCode;

    creditCardModel = CreditCard(
        cardNumber: cardNumber,
        expiryDate: expiryDate,
        cardHolderName: cardHolderName,
        cvvCode: cvvCode,
        isCvvFocused: isCvvFocused);
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
            margin: const EdgeInsets.only(left: 16, right: 16),
            child: TextFormField(
              obscureText: widget.obscureNumber,
              controller: _cardNumberController,
              onEditingComplete: () {
                FocusScope.of(context).requestFocus(expiryDateNode);
              },
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: AppLocalizations.of(context)
                    .translate('credit_card_number'),
                hintText: 'XXXX XXXX XXXX XXXX',
              ),
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              validator: (String? value) {
                if (value == null || value.isEmpty || value.length < 16) {
                  return AppLocalizations.of(context)
                      .translate('card_number_error');
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
                      border: const OutlineInputBorder(),
                      labelText: AppLocalizations.of(context)
                          .translate('credit_card_expire_date'),
                      hintText: 'XX/XX',
                    ),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)
                            .translate('card_date_error');
                      }

                      final DateTime now = DateTime.now();
                      final List<String> date = value.split(RegExp('/'));
                      final int month = int.parse(date.first);
                      final int year = int.parse('20${date.last}');
                      final DateTime cardDate = DateTime(year, month);

                      if (cardDate.isBefore(now) || month > 12 || month == 0) {
                        return AppLocalizations.of(context)
                            .translate('card_date_error');
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
                      border: const OutlineInputBorder(),
                      labelText: AppLocalizations.of(context).translate('cvv'),
                      hintText: widget.isAmex ? 'XXXX' : 'XXX',
                    ),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    onChanged: (String text) {
                      setState(() {
                        cvvCode = text;
                      });
                    },
                    validator: (String? value) {
                      if (value == null ||
                          value.isEmpty ||
                          value.length != (widget.isAmex ? 4 : 3)) {
                        return AppLocalizations.of(context)
                            .translate('cvv_error');
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
                border: const OutlineInputBorder(),
                labelText:
                    AppLocalizations.of(context).translate('card_holder'),
              ),
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.done,
              onEditingComplete: () {
                onCreditCardChange(creditCardModel);
              },
              onFieldSubmitted: (_) => widget.onSubmit(),
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return AppLocalizations.of(context)
                      .translate('card_holder_error');
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
