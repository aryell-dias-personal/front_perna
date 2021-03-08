import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:perna/constants/constants.dart';
import 'package:perna/helpers/app_localizations.dart';
import 'package:perna/helpers/show_snack_bar.dart';
import 'package:perna/main.dart';
import 'package:perna/models/credit_card.dart';
import 'package:perna/pages/credit_card_page.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:perna/services/payments.dart';
import 'package:perna/services/sign_in.dart';

class WalletPage extends StatefulWidget { 
  @override
  _WalletPageState createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> with TickerProviderStateMixin {
  List<CreditCard> creditCards = <CreditCard>[];
  bool isLoading = true;
  String userToken;
  String selectedCardId;

  @override
  void initState() {
    super.initState();
    getIt<SignInService>().getRefreshToken().then((String token) {
      setState(() {
        userToken = token;
      });
      getIt<PaymentsService>().listCard(userToken).then(
        (List<CreditCard> creditCards) {
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
        child: SpinKitDoubleBounce(
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
        margin: const EdgeInsets.only(top: 10),
        child: Builder(
          builder: (BuildContext context) {
            return ListView.separated(
              itemCount: creditCards.length,
              separatorBuilder: (BuildContext context, int index) {
                return const Divider();
              },
              itemBuilder: (BuildContext context, int index) {
                final CreditCard currCreditCard = creditCards[index];
                return AnimatedSize(
                  vsync: this,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    padding: const EdgeInsets.only(bottom: 5, top: 5, left: 10, right: 10),
                    child: Material(
                      elevation: 3,
                      color: Theme.of(context).primaryColor,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))
                      ),
                      child: InkWell(
                        overlayColor: MaterialStateProperty.all(Theme.of(context).splashColor),
                        onLongPress: () {
                          setState(() {
                            selectedCardId = selectedCardId != currCreditCard.id ? currCreditCard.id : null;
                          });
                        },
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
                                  if(index == 0) Container(
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
                                          AppLocalizations.of(context).translate('default_credit_card'),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context).primaryColor
                                          ),
                                        ),  
                                      ],
                                    )
                                  ),
                                  if(selectedCardId == currCreditCard.id) Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: <Widget>[
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
                                ]
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    currCreditCard.cardHolderName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).backgroundColor
                                    ),
                                  ), 
                                  SizedBox(
                                    height: 48,
                                    width: 48,
                                    child: brandToCardType.containsKey(currCreditCard.brand) ? Image.asset(
                                      cardTypeIconAsset[
                                        brandToCardType[
                                          currCreditCard.brand
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
        builder: (BuildContext context) =>
          isLoading || creditCards.length == maxCardNumber ? const SizedBox() : (selectedCardId == null ? FloatingActionButton(
            heroTag: '3',
            backgroundColor: Theme.of(context).primaryColor,
            tooltip: AppLocalizations.of(context).translate('add_credit_card'),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute<CreditCardPage>(
                builder: (BuildContext context) => CreditCardPage(
                    userToken: userToken,
                  )
                )
              );
            },
            child: Icon(Icons.credit_card, color: Theme.of(context).backgroundColor),
          ) : SpeedDial(
            icon: Icons.edit_outlined,
            marginEnd: 14,
            iconTheme: IconThemeData(
              color: Theme.of(context).backgroundColor,
              opacity: 1,
            ),
            heroTag: '3',
            backgroundColor: Theme.of(context).primaryColor,
            children: (creditCards?.first?.id == selectedCardId ? <SpeedDialChild>[] : <SpeedDialChild>[
              SpeedDialChild(
                onTap: () async {
                  setState(() { isLoading = true; });
                  final int statusCode = await getIt<PaymentsService>().turnCardDefault(selectedCardId, userToken);
                  if(statusCode == 200) {
                    final List<CreditCard> creditCards = await getIt<PaymentsService>().listCard(userToken);
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
            ]) + <SpeedDialChild>[
              SpeedDialChild(
                onTap: () async {
                  setState(() { isLoading = true; });
                  final int statusCode = await getIt<PaymentsService>().deleteCard(selectedCardId, userToken);
                  if(statusCode == 200) {
                    final List<CreditCard> creditCards = await getIt<PaymentsService>().listCard(userToken);
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
    );
  }
}