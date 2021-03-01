import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:perna/helpers/appLocalizations.dart';
import 'package:perna/helpers/myDecoder.dart';
import 'package:perna/pages/creditCardPage.dart';
import 'package:perna/services/payments.dart';

class WalletPage extends StatefulWidget {
  final Future<IdTokenResult> Function() getRefreshToken;
 
  const WalletPage({@required this.getRefreshToken});

  @override
  _WalletPageState createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  final PaymentsService paymentsService = PaymentsService(myDecoder: MyDecoder());
  bool isLoading = true;
  String userToken;

  @override
  void initState() {
    super.initState();
    widget.getRefreshToken().then((IdTokenResult idTokenResult) {
      setState(() {
        isLoading = false;
        userToken = idTokenResult.token;
      });
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
      //TODO: Montar lista de cartões de créditos e contas para recebimento destacando selecionado(s)
      body: true ? Center(
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
      ) : Builder(
        builder: (context) {
          return ListView.separated(
            itemCount: 0,
            separatorBuilder: (context, index) {
              return Divider();
            },
            itemBuilder: (context, index) {
              return SizedBox();
            }
          );
        }
      ),
      floatingActionButton: isLoading ? null : FloatingActionButton(
        heroTag: "3",
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(Icons.credit_card, color: Theme.of(context).backgroundColor),
        tooltip: AppLocalizations.of(context).translate("creditCard"),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => CreditCardPage(
                paymentsService: paymentsService,
                userToken: userToken,
              )
            )
          );
        },
      )
    );
  }
}