import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:loading/loading.dart';
import 'package:perna/constants/constants.dart';
import 'package:perna/helpers/appLocalizations.dart';
import 'package:perna/helpers/myDecoder.dart';
import 'package:perna/models/creditCard.dart';
import 'package:perna/pages/creditCardPage.dart';
import 'package:perna/services/payments.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class WalletPage extends StatefulWidget {
  final Future<IdTokenResult> Function() getRefreshToken;
 
  const WalletPage({@required this.getRefreshToken});

  @override
  _WalletPageState createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> with TickerProviderStateMixin {
  final PaymentsService paymentsService = PaymentsService(myDecoder: MyDecoder());
  List<CreditCard> creditCards = [];
  bool isLoading = true;
  String userToken;
  String selectedCardId;

  @override
  void initState() {
    super.initState();
    widget.getRefreshToken().then((IdTokenResult idTokenResult) {
      setState(() {
        userToken = idTokenResult.token;
      });
      paymentsService.listCard(userToken).then(
        (creditCards) {
          setState(() {
            this.creditCards = creditCards;
            isLoading = false;
          });
        }
      );
    });
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
                    text: AppLocalizations.of(context).translate("wallet"), 
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)
                  ),
                ],
              ) 
              , maxLines: 2
            ),
            SizedBox(width: 5),
            Icon(Icons.account_balance_wallet_outlined, size: 30),
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
      body: isLoading ? Center(
        child: Loading(
          indicator: BallPulseIndicator(), 
          size: 100.0, color: Theme.of(context).primaryColor
        )
      ) : (creditCards.isEmpty ? Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Image.asset('assets/empty_wallet.png', scale: 2),
            Text(
              AppLocalizations.of(context).translate("noCreditCard"),
              textAlign: TextAlign.center, 
              style: TextStyle(fontSize: 20)
            ),
            Text(
              AppLocalizations.of(context).translate("noCreditCardDescription"),
              textAlign: TextAlign.center, 
              style: TextStyle(fontSize: 17),
            )
          ],
        )
      ) : Container(
        margin: EdgeInsets.only(top: 10),
        child: Builder(
          builder: (context) {
            return ListView.separated(
              itemCount: creditCards.length,
              separatorBuilder: (context, index) {
                return Divider();
              },
              itemBuilder: (context, index) {
                CreditCard currCreditCard = creditCards[index];
                return AnimatedSize(
                  vsync: this,
                  curve: Curves.linear,
                  duration: Duration(milliseconds: 200),
                  child: Container(
                    padding: EdgeInsets.only(bottom: 5, top: 5, left: 10, right: 10),
                    child: Material(
                      elevation: 3,
                      color: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))
                      ),
                      child: InkWell(
                        onLongPress: () {
                          setState(() {
                            selectedCardId = selectedCardId != currCreditCard.id ? currCreditCard.id : null;
                          });
                        },
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
                                  (index != 0 ? SizedBox() 
                                  : Container(
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
                                          AppLocalizations.of(context).translate("defaultCreditCard"),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context).primaryColor
                                          ),
                                        ),  
                                      ],
                                    )
                                  )),
                                  (selectedCardId != currCreditCard.id ? SizedBox() 
                                  : Row(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        Icon(
                                          Icons.check_circle_outline, 
                                          color: Theme.of(context).backgroundColor,
                                        ),
                                        SizedBox(width: 2),
                                        Text(
                                          AppLocalizations.of(context).translate("selected"),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context).backgroundColor
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
                                    currCreditCard.cardHolderName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).backgroundColor
                                    ),
                                  ),  
                                  (!BrandToCardType.containsKey(currCreditCard.brand) ? Container(
                                    height: 48,
                                    width: 48,
                                  ) : Image.asset(
                                    CardTypeIconAsset[BrandToCardType[currCreditCard.brand]],
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
                                    currCreditCard.cardNumber,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).backgroundColor
                                    ),
                                  ),
                                  Text(
                                    currCreditCard.expiryDate,
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
                  )
                );
              }
            );
          }
        ))
      ),
      floatingActionButton: isLoading ? null : (selectedCardId == null ? FloatingActionButton(
        heroTag: "3",
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(Icons.credit_card, color: Theme.of(context).backgroundColor),
        tooltip: AppLocalizations.of(context).translate("addCreditCard"),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => CreditCardPage(
                paymentsService: paymentsService,
                userToken: userToken,
              )
            )
          );
        },
      ) : SpeedDial(
        icon: Icons.edit_outlined,
        marginEnd: 14,
        iconTheme: IconThemeData(
          color: Theme.of(context).backgroundColor,
          opacity: 1,
        ),
        heroTag: "3",
        backgroundColor: Theme.of(context).primaryColor,
        children: (creditCards?.first?.id == selectedCardId ? <SpeedDialChild>[] : [
          SpeedDialChild(
            child: Icon(
              Icons.star_border, 
              color: Theme.of(context).backgroundColor
            ),
            label: AppLocalizations.of(context).translate("turnCreditCardDefault"),
            backgroundColor: Colors.amberAccent
          )
        ]) + [
          SpeedDialChild(
            child: Icon(
              Icons.delete_outline, 
              color: Theme.of(context).backgroundColor
            ),
            label: AppLocalizations.of(context).translate("deleteCreditCard"),
            backgroundColor: Colors.redAccent
          )
        ],
        // icon: Icon(Icons.mode_outlined, color: Theme.of(context).backgroundColor),
        tooltip: AppLocalizations.of(context).translate("editCreditCard"),
      ))
    );
  }
}