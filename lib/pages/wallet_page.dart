import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:loading/loading.dart';
import 'package:perna/constants/constants.dart';
import 'package:perna/helpers/app_localizations.dart';
import 'package:perna/helpers/show_snack_bar.dart';
import 'package:perna/models/credit_card.dart';
import 'package:perna/pages/credit_card_page.dart';
import 'package:perna/services/payments.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class WalletPage extends StatefulWidget {
  final Future<String> Function() getRefreshToken;
  final PaymentsService paymentsService;
 
  const WalletPage({
    @required this.getRefreshToken,
    @required this.paymentsService
  });

  @override
  _WalletPageState createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> with TickerProviderStateMixin {
  List<CreditCard> creditCards = [];
  bool isLoading = true;
  String userToken;
  String selectedCardId;

  @override
  void initState() {
    super.initState();
    widget.getRefreshToken().then((String token) {
      setState(() {
        userToken = token;
      });
      widget.paymentsService.listCard(userToken).then(
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
                  fontFamily: 'ProductSans'
                ),
                children:  <TextSpan>[
                  TextSpan(
                    text: AppLocalizations.of(context).translate('wallet'), 
                    style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)
                  ),
                ],
              ) 
              , maxLines: 2
            ),
            const SizedBox(width: 5),
            const Icon(Icons.account_balance_wallet_outlined, size: 30),
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
              AppLocalizations.of(context).translate('no_credit_card'),
              textAlign: TextAlign.center, 
              style: const TextStyle(fontSize: 20)
            ),
            Text(
              AppLocalizations.of(context).translate('no_credit_card_description'),
              textAlign: TextAlign.center, 
              style: const TextStyle(fontSize: 17),
            )
          ],
        )
      ) : Container(
        margin: EdgeInsets.only(top: 10),
        child: Builder(
          builder: (BuildContext context) {
            return ListView.separated(
              itemCount: creditCards.length,
              separatorBuilder: (BuildContext context, index) {
                return const Divider();
              },
              itemBuilder: (BuildContext context, index) {
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
                        overlayColor: MaterialStateProperty.all(Theme.of(context).splashColor),
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
                                        const SizedBox(width: 2),
                                        Text(
                                          AppLocalizations.of(context).translate('default_credit_card'),
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
                                        const SizedBox(width: 2),
                                        Text(
                                          AppLocalizations.of(context).translate('selected_credit_card'),
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
                                  (!brandToCardType.containsKey(currCreditCard.brand) ? Container(
                                    height: 48,
                                    width: 48,
                                  ) : Image.asset(
                                    cardTypeIconAsset[brandToCardType[currCreditCard.brand]],
                                      height: 48,
                                      width: 48
                                    )
                                  ),
                                ]
                              ),
                              const SizedBox(height: 10),
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
                              const SizedBox(height: 10),
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
      floatingActionButton: Builder(
        builder: (BuildContext context) => (
          isLoading || creditCards.length == maxCardNumber ? SizedBox() : (selectedCardId == null ? FloatingActionButton(
            heroTag: '3',
            backgroundColor: Theme.of(context).primaryColor,
            child: Icon(Icons.credit_card, color: Theme.of(context).backgroundColor),
            tooltip: AppLocalizations.of(context).translate('add_credit_card'),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (BuildContext context) => CreditCardPage(
                    paymentsService: widget.paymentsService,
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
            heroTag: '3',
            backgroundColor: Theme.of(context).primaryColor,
            children: (creditCards?.first?.id == selectedCardId ? <SpeedDialChild>[] : [
              SpeedDialChild(
                onTap: () async {
                  setState(() { isLoading = true; });
                  int statusCode = await widget.paymentsService.turnCardDefault(selectedCardId, userToken);
                  if(statusCode == 200) {
                    List<CreditCard> creditCards = await widget.paymentsService.listCard(userToken);
                    setState(() { this.creditCards = creditCards; });
                    showSnackBar(AppLocalizations.of(context).translate('successfully_turned_card_default'), 
                      Colors.greenAccent, context);
                  } else {
                    showSnackBar(AppLocalizations.of(context).translate('unsuccessfully_turned_card_default'), 
                      Colors.redAccent, context);
                  }
                  setState(() { 
                    isLoading = false;
                    selectedCardId = null;
                  });
                },
                child: Icon(
                  Icons.star_border, 
                  color: Theme.of(context).backgroundColor
                ),
                label: AppLocalizations.of(context).translate('turn_credit_card_default'),
                backgroundColor: Colors.amberAccent,
              )
            ]) + [
              SpeedDialChild(
                onTap: () async {
                  setState(() { isLoading = true; });
                  int statusCode = await widget.paymentsService.deleteCard(selectedCardId, userToken);
                  if(statusCode == 200) {
                    List<CreditCard> creditCards = await widget.paymentsService.listCard(userToken);
                    setState(() { this.creditCards = creditCards; });
                    showSnackBar(AppLocalizations.of(context).translate('successfully_delete_card'), 
                      Colors.greenAccent, context);
                  } else {
                    showSnackBar(AppLocalizations.of(context).translate('unsuccessfully_delete_card'), 
                      Colors.redAccent, context);
                  }
                  setState(() { 
                    isLoading = false;
                    selectedCardId = null;
                  });
                },
                child: Icon(
                  Icons.delete_outline, 
                  color: Theme.of(context).backgroundColor
                ),
                label: AppLocalizations.of(context).translate('delete_credit_card'),
                backgroundColor: Colors.redAccent
              )
            ],
            tooltip: AppLocalizations.of(context).translate('edit_credit_card'),
          ))
        )
      )
    );
  }
}