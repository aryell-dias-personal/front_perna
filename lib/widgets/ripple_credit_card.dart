import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:perna/helpers/app_localizations.dart';
import 'package:perna/models/credit_card.dart';
import 'package:perna/widgets/card_brand.dart';

class RippleCreditCard extends StatelessWidget {
  const RippleCreditCard(
      {@required this.isDefault,
      @required this.isSelected,
      @required this.creditCard,
      this.onLongPress,
      this.top = 15});

  final Function() onLongPress;
  final double top;
  final bool isDefault;
  final bool isSelected;
  final CreditCard creditCard;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(bottom: 5, top: top, left: 10, right: 10),
        child: Material(
          elevation: 3,
          color: Theme.of(context).primaryColor,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10))),
          child: InkWell(
              overlayColor:
                  MaterialStateProperty.all(Theme.of(context).splashColor),
              onLongPress: onLongPress,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              child: Container(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              if (isDefault)
                                Container(
                                    padding: const EdgeInsets.only(
                                        left: 5, right: 10, top: 3, bottom: 3),
                                    decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(50)),
                                        color:
                                            Theme.of(context).backgroundColor),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: <Widget>[
                                        Icon(
                                          Icons.star_border,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          AppLocalizations.of(context)
                                              .translate('default_credit_card'),
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context)
                                                  .primaryColor),
                                        ),
                                      ],
                                    )),
                              if (isSelected)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    Icon(
                                      Icons.check_circle_outline,
                                      color: Theme.of(context).backgroundColor,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      AppLocalizations.of(context)
                                          .translate('selected_credit_card'),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context)
                                              .backgroundColor),
                                    ),
                                  ],
                                )
                            ]),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                creditCard.cardHolderName,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).backgroundColor),
                              ),
                              CardBrand(brand: creditCard.brand)
                            ]),
                        const SizedBox(height: 10),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                creditCard.cardNumber,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).backgroundColor),
                              ),
                              Text(
                                creditCard.expiryDate,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).backgroundColor),
                              ),
                            ]),
                        const SizedBox(height: 10),
                      ]))),
        ));
  }
}
