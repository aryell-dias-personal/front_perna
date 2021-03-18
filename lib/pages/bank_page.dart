import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:perna/helpers/app_localizations.dart';
import 'package:perna/models/bank_account.dart';
import 'package:perna/widgets/form/bank_form.dart';

class BankPage extends StatefulWidget {
  BankPage(
      {this.bankAccount, this.readOnly = false, this.onSubmmitBankAccount}) {
    if (!readOnly) assert(onSubmmitBankAccount != null);
  }

  final void Function(BankAccount) onSubmmitBankAccount;
  final BankAccount bankAccount;
  final bool readOnly;

  @override
  _BankPageState createState() => _BankPageState();
}

class _BankPageState extends State<BankPage> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          brightness: Theme.of(context).brightness,
          centerTitle: true,
          title: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
            Text(AppLocalizations.of(context).translate('bank'),
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 30.0)),
            const SizedBox(width: 5),
            const Icon(Icons.account_balance_outlined, size: 30),
          ]),
          backgroundColor: Theme.of(context).backgroundColor,
          iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
          textTheme: TextTheme(
              headline6: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 20,
                  fontFamily:
                      Theme.of(context).textTheme.headline6.fontFamily)),
        ),
        body: Material(
            child: isLoading
                ? Center(
                    child: SpinKitDoubleBounce(
                        size: 100.0, color: Theme.of(context).primaryColor))
                : SingleChildScrollView(
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                        BankForm(
                          readOnly: widget.readOnly,
                          onSubmmitBankAccount: widget.onSubmmitBankAccount,
                        ),
                      ]))));
  }
}
