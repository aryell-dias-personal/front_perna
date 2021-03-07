import 'package:flutter/material.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:loading/loading.dart';
import 'package:perna/constants/constants.dart';
import 'package:perna/helpers/app_localizations.dart';
import 'package:perna/helpers/credit_card.dart';
import 'package:perna/helpers/show_snack_bar.dart';
import 'package:perna/main.dart';
import 'package:perna/models/asked_point.dart';
import 'package:perna/models/credit_card.dart';
import 'package:perna/services/payments.dart';
import 'package:perna/widgets/titled_value_widget.dart';
import 'package:intl/intl.dart';

class AskedPointConfirmationPage extends StatefulWidget {  
   const AskedPointConfirmationPage({
    @required this.clear,
    @required this.userToken,
    @required this.askedPoint,
    @required this.defaultCreditCard
  });

  final String userToken;  
  final AskedPoint askedPoint;
  final CreditCard defaultCreditCard;
  final Function() clear;
  
  @override
  _AskedPointConfirmationPageState createState() => 
    _AskedPointConfirmationPageState();
}

class _AskedPointConfirmationPageState extends State<AskedPointConfirmationPage> {
  bool isLoading = false;

  final DateFormat format = DateFormat('dd/MM/yyyy HH:mm');
  final DateFormat formatDate = DateFormat('dd/MM/yyyy');
  
  Future<void> _onPressed(BuildContext context) async {
    setState(() { isLoading = true; });
    final int statusCode = 
      await getIt<PaymentsService>().confirmAskedPointPayment(
        widget.askedPoint, widget.userToken
      );
    if(statusCode == 200) {
      widget.clear();
      Navigator.popUntil(context, (Route<dynamic> route) => route.isFirst);
      showSnackBar(
        AppLocalizations.of(context).translate('successfully_added_order'), 
        Colors.greenAccent, context);
    } else {
      setState(() { isLoading = false; });
      showSnackBar(
        AppLocalizations.of(context).translate('unsuccessfully_added_order'), 
        Colors.redAccent, context);
    }
  }

  String parseDuration(){
    final Duration duration = 
      widget.askedPoint.askedStartAt ?? widget.askedPoint.askedEndAt;
    if(duration != null) {
      final DateTime currTime = widget.askedPoint.date.add(duration);
      return format.format(currTime);
    }
    return formatDate.format(widget.askedPoint.date);
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
                  fontFamily: 'ProductSans'
                ),
                children:  <TextSpan>[
                  TextSpan(
                    text: AppLocalizations.of(context).translate('pay'), 
                    style: 
                      const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)
                  ),
                ],
              ) 
              , maxLines: 2
            ),
            const SizedBox(width: 5),
            const Icon(Icons.account_balance, size: 30),
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
      body: Container(
        child: isLoading ? Center(
          child: Loading(
            indicator: BallPulseIndicator(), 
            size: 100.0, 
            color: Theme.of(context).primaryColor
          )
        ) : SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.only(bottom: 5, top: 15, left: 10, right: 10),
                child: Material(
                  elevation: 3,
                  color: Theme.of(context).primaryColor,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10))
                  ),
                  child: InkWell(
                    overlayColor: MaterialStateProperty.all(Theme.of(context).splashColor),
                    onTap: ()  {},
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
                              Container(
                                padding: const EdgeInsets.only(left: 5, right: 10, top: 3, bottom: 3),
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(Radius.circular(50)),
                                  color: Theme.of(context).backgroundColor
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                                        color: Theme.of(context).primaryColor
                                      ),
                                    ),  
                                  ],
                                )
                              )
                            ]
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                widget.defaultCreditCard.cardHolderName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).backgroundColor
                                ),
                              ),  
                              SizedBox(
                                height: 48,
                                width: 48,
                                child: !brandToCardType.containsKey(widget.defaultCreditCard.brand) ? Image.asset(
                                  cardTypeIconAsset[
                                    brandToCardType[
                                      widget.defaultCreditCard.brand
                                    ]
                                  ],
                                  height: 48,
                                  width: 48
                                ) : const SizedBox()
                              )
                            ]
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                widget.defaultCreditCard.cardNumber,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).backgroundColor
                                ),
                              ),
                              Text(
                                widget.defaultCreditCard.expiryDate,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).backgroundColor
                                ),
                              ),
                            ]
                          ),
                          const SizedBox(height: 10),
                        ]
                      )
                    )
                  ),
                )
              ),
              const Divider(), 
              TextButton(
                style: ButtonStyle(
                  overlayColor: 
                    MaterialStateProperty.all(Theme.of(context).splashColor)
                ),
                onPressed: (){
                  Navigator.of(context).pop();
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        TitledValueWidget(
                          title: 
                            AppLocalizations.of(context).translate('order'),
                          value: parseDuration(),
                        ),
                        Icon(
                          Icons.chevron_left,
                          color: Theme.of(context).primaryColor,
                        )
                      ]
                    ),
                    const SizedBox(height: 10),
                    Image.memory(widget.askedPoint.staticMap),
                    const SizedBox(height: 10),
                  ],
                )
              ),            
              const Divider(),
              Container(
                padding: const EdgeInsets.only(
                  bottom: 5, top: 5, left: 10, right: 10),
                child: Material(
                  elevation: 3,
                  color: Theme.of(context).backgroundColor,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10))
                  ),
                  child: InkWell(
                    overlayColor: MaterialStateProperty.all(
                      Theme.of(context).splashColor),
                    onTap: ()  {},
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Text(
                            AppLocalizations.of(context)
                              .translate('order_value'),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12.0,
                              color: Theme.of(context).primaryColor
                            ),
                          ),
                          Text(
                            formatAmount(
                              widget.askedPoint.amount, 
                              widget.askedPoint.currency, 
                              AppLocalizations.of(context).locale
                            ),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 30.0,
                              color: Theme.of(context).primaryColor
                            ),
                          )
                        ]
                      )
                    )
                  ),
                )
              ),
            ]
          )
        )
      ),
      floatingActionButton: Builder(
        builder: (BuildContext context) => isLoading ? 
          const SizedBox() : FloatingActionButton.extended(
          onPressed: () => _onPressed(context),
          label: Row(
            children: <Widget>[
              Text(
                AppLocalizations.of(context).translate('do_payment'),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15.0,
                  color: Theme.of(context).backgroundColor
                ),
              ),
              const SizedBox(width: 5),
              Icon(
                Icons.payment, 
                color: Theme.of(context).backgroundColor,
              ),
            ]
          ),
          backgroundColor: Theme.of(context).primaryColor,
        )
      ),
    );
  }
}