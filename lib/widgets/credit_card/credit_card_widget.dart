import 'dart:math';
import 'package:flutter/material.dart';
import 'package:perna/helpers/app_localizations.dart';
import 'package:perna/widgets/credit_card/credit_card_animation.dart';

class CreditCardWidget extends StatefulWidget {
  const CreditCardWidget({
    required this.cardNumber,
    required this.expiryDate,
    required this.cvvCode,
    required this.showBackView,
    required this.isAmex,
    required this.cardType,
    this.cardHolderName = '',
    this.animationDuration = const Duration(milliseconds: 500),
    this.height,
    this.width,
    this.labelExpiredDate = 'MM/YY',
  });

  final String cardNumber;
  final String expiryDate;
  final String cardHolderName;
  final String cvvCode;
  final bool showBackView;
  final Duration animationDuration;
  final double? height;
  final double? width;

  final Widget cardType;
  final bool isAmex;
  final String labelExpiredDate;

  @override
  _CreditCardWidgetState createState() => _CreditCardWidgetState();
}

class _CreditCardWidgetState extends State<CreditCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> _frontRotation;
  late Animation<double> _backRotation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _frontRotation = TweenSequence<double>(
      <TweenSequenceItem<double>>[
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: 0.0, end: pi / 2)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 50.0,
        ),
        TweenSequenceItem<double>(
          tween: ConstantTween<double>(pi / 2),
          weight: 50.0,
        ),
      ],
    ).animate(controller);

    _backRotation = TweenSequence<double>(
      <TweenSequenceItem<double>>[
        TweenSequenceItem<double>(
          tween: ConstantTween<double>(pi / 2),
          weight: 50.0,
        ),
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: -pi / 2, end: 0.0)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 50.0,
        ),
      ],
    ).animate(controller);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    final Orientation orientation = MediaQuery.of(context).orientation;

    if (widget.showBackView) {
      controller.forward();
    } else {
      controller.reverse();
    }

    return Stack(
      children: <Widget>[
        AnimationCard(
          animation: _frontRotation,
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                stops: const <double>[0.1, 0.4, 0.7, 0.9],
                colors: <Color>[
                  Theme.of(context).primaryColor.withOpacity(1),
                  Theme.of(context).primaryColor.withOpacity(0.97),
                  Theme.of(context).primaryColor.withOpacity(0.90),
                  Theme.of(context).primaryColor.withOpacity(0.86),
                ],
              ),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Colors.black38,
                  blurRadius: 5,
                ),
              ],
            ),
            width: widget.width ?? width,
            height: widget.height ??
                (orientation == Orientation.portrait ? height / 4 : height / 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
                    child: widget.cardType,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text(
                      widget.cardNumber.isEmpty
                          ? 'XXXX XXXX XXXX XXXX'
                          : widget.cardNumber
                              .replaceAll(RegExp(r'(?<=.{4})\d(?=.* )'), '*'),
                      style: Theme.of(context).textTheme.headline6!.merge(
                            TextStyle(
                                color: Theme.of(context).backgroundColor,
                                fontFamily: 'halter',
                                fontSize: 16),
                          ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text(
                      widget.expiryDate.isEmpty
                          ? widget.labelExpiredDate
                          : widget.expiryDate,
                      style: Theme.of(context).textTheme.headline6!.merge(
                            TextStyle(
                                color: Theme.of(context).backgroundColor,
                                fontFamily: 'halter',
                                fontSize: 16),
                          ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                    child: Text(
                      widget.cardHolderName.isEmpty
                          ? AppLocalizations.of(context)
                              .translate('card_holder')
                              .toUpperCase()
                          : widget.cardHolderName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.headline6!.merge(
                            TextStyle(
                                color: Theme.of(context).backgroundColor,
                                fontFamily: 'halter',
                                fontSize: 16),
                          ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimationCard(
          animation: _backRotation,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                stops: const <double>[0.1, 0.4, 0.7, 0.9],
                colors: <Color>[
                  Theme.of(context).primaryColor.withOpacity(1),
                  Theme.of(context).primaryColor.withOpacity(0.97),
                  Theme.of(context).primaryColor.withOpacity(0.90),
                  Theme.of(context).primaryColor.withOpacity(0.86),
                ],
              ),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Colors.black38,
                  blurRadius: 5,
                ),
              ],
            ),
            margin: const EdgeInsets.all(16),
            width: widget.width ?? width,
            height: widget.height ??
                (orientation == Orientation.portrait ? height / 4 : height / 2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: Container(
                    margin: const EdgeInsets.only(top: 16),
                    height: 48,
                    color: Colors.black,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    margin: const EdgeInsets.only(top: 16),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          flex: 9,
                          child: Container(
                            height: 48,
                            color: Colors.black12,
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Container(
                            color: Theme.of(context).primaryColor,
                            child: Padding(
                              padding: const EdgeInsets.all(5),
                              child: Text(
                                widget.cvvCode.isEmpty
                                    ? (widget.isAmex ? 'XXXX' : 'XXX')
                                    : widget.cvvCode
                                        .replaceAll(RegExp(r'\d'), '*'),
                                maxLines: 1,
                                style: Theme.of(context)
                                    .textTheme
                                    .headline6!
                                    .merge(
                                      const TextStyle(
                                          color: Colors.black,
                                          fontFamily: 'halter',
                                          fontSize: 16),
                                    ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 16, right: 16, bottom: 16),
                      child: widget.cardType,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
