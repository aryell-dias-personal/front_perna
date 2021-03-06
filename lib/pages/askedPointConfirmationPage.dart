import 'package:flutter/material.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:loading/loading.dart';
import 'package:perna/constants/constants.dart';
import 'package:perna/helpers/appLocalizations.dart';
import 'package:perna/helpers/creditCard.dart';
import 'package:perna/helpers/showSnackBar.dart';
import 'package:perna/models/askedPoint.dart';
import 'package:perna/models/creditCard.dart';
import 'package:perna/services/payments.dart';
import 'package:perna/widgets/titledValueWidget.dart';
import 'package:intl/intl.dart';

class AskedPointConfirmationPage extends StatefulWidget {
  final PaymentsService paymentsService;
  final String userToken;  
  final AskedPoint askedPoint;
  final CreditCard defaultCreditCard;
  final Function() clear;
  
  AskedPointConfirmationPage({
    @required this.clear,
    @required this.paymentsService,
    @required this.userToken,
    @required this.askedPoint,
    @required this.defaultCreditCard
  });

  @override
  _AskedPointConfirmationPageState createState() => _AskedPointConfirmationPageState();
}

class _AskedPointConfirmationPageState extends State<AskedPointConfirmationPage> {
  bool isLoading = false;

  final DateFormat format = DateFormat('dd/MM/yyyy HH:mm');
  final DateFormat formatDate = DateFormat('dd/MM/yyyy');
  
  void _onPressed(context) async {
    setState(() { isLoading = true; });
    int statusCode = await widget.paymentsService.confirmAskedPointPayment(widget.askedPoint, widget.userToken);
    if(statusCode == 200) {
      widget.clear();
      Navigator.popUntil(context, (route) => route.isFirst);
      showSnackBar(AppLocalizations.of(context).translate("successfully_added_order"), 
        Colors.greenAccent, context);
    } else {
      setState(() { isLoading = false; });
      showSnackBar(AppLocalizations.of(context).translate("unsuccessfully_added_order"), 
        Colors.redAccent, context);
    }
  }

  String parseDuration(){
    Duration duration = widget.askedPoint.askedStartAt ?? widget.askedPoint.askedEndAt;
    if(duration != null) {
      DateTime currTime = widget.askedPoint.date.add(duration);
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
                  fontFamily: "ProductSans"
                ),
                children:  <TextSpan>[
                  TextSpan(
                    text: AppLocalizations.of(context).translate("pay"), 
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)
                  ),
                ],
              ) 
              , maxLines: 2
            ),
            SizedBox(width: 5),
            Icon(Icons.account_balance, size: 30),
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
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(bottom: 5, top: 15, left: 10, right: 10),
                child: Material(
                  elevation: 3,
                  color: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10))
                  ),
                  child: InkWell(
                    overlayColor: MaterialStateProperty.all(Theme.of(context).splashColor),
                    onTap: ()  {},
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: EdgeInsets.only(left: 5, right: 10, top: 3, bottom: 3),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(50)),
                                  color: Theme.of(context).backgroundColor
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    Icon(
                                      Icons.star_border, 
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    SizedBox(width: 2),
                                    Text(
                                      AppLocalizations.of(context).translate("default_credit_card"),
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
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                widget.defaultCreditCard.cardHolderName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).backgroundColor
                                ),
                              ),  
                              (!BrandToCardType.containsKey(widget.defaultCreditCard.brand) ? Container(
                                height: 48,
                                width: 48,
                              ) : Image.asset(
                                CardTypeIconAsset[BrandToCardType[widget.defaultCreditCard.brand]],
                                  height: 48,
                                  width: 48
                                )
                              ),
                            ]
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
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
                          SizedBox(height: 10),
                        ]
                      )
                    )
                  ),
                )
              ),
              Divider(), 
              TextButton(
                style: ButtonStyle(
                  overlayColor: MaterialStateProperty.all(Theme.of(context).splashColor)
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
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        TitledValueWidget(
                          title: AppLocalizations.of(context).translate("order"),
                          value: parseDuration(),
                        ),
                        Icon(
                          Icons.chevron_left,
                          color: Theme.of(context).primaryColor,
                        )
                      ]
                    ),
                    SizedBox(height: 10),
                    Image.memory(widget.askedPoint.staticMap),
                    SizedBox(height: 10),
                  ],
                )
              ),            
              Divider(),
              Container(
                padding: EdgeInsets.only(bottom: 5, top: 5, left: 10, right: 10),
                child: Material(
                  elevation: 3,
                  color: Theme.of(context).backgroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10))
                  ),
                  child: InkWell(
                    overlayColor: MaterialStateProperty.all(Theme.of(context).splashColor),
                    onTap: ()  {},
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Text(
                            AppLocalizations.of(context).translate("order_value"),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12.0,
                              color: Theme.of(context).primaryColor
                            ),
                          ),
                          Text(
                            formatAmount(widget.askedPoint.amount, widget.askedPoint.currency, AppLocalizations.of(context).locale),
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
        builder: (context) => isLoading ? SizedBox() :  FloatingActionButton.extended(
          onPressed: () => _onPressed(context),
          label: Row(
            children: <Widget>[
              Text(
                AppLocalizations.of(context).translate("do_payment"),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15.0,
                  color: Theme.of(context).backgroundColor
                ),
              ),
              SizedBox(width: 5),
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