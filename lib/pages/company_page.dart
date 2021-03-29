import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:perna/helpers/app_localizations.dart';
import 'package:perna/helpers/show_snack_bar.dart';
import 'package:perna/main.dart';
import 'package:perna/models/bank_account.dart';
import 'package:perna/models/company.dart';
import 'package:perna/pages/bank_page.dart';
import 'package:perna/widgets/form/company_form.dart';
import 'package:perna/services/company.dart';
import 'package:perna/services/sign_in.dart';

enum CompanyOptions { consultBankData }

class CompanyPage extends StatefulWidget {
  CompanyPage({this.company, this.readOnly = false, this.email}) {
    if (readOnly) {
      assert(company != null);
    }
    assert(email != null);
  }

  final Company company;
  final bool readOnly;
  final String email;

  @override
  _CompanyPageState createState() => _CompanyPageState();
}

class _CompanyPageState extends State<CompanyPage> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          brightness: Theme.of(context).brightness,
          centerTitle: true,
          title: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
            if (widget.readOnly)
              Text(AppLocalizations.of(context).translate('provider'),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 30.0)),
            if (!widget.readOnly)
              Text(AppLocalizations.of(context).translate('addProvider'),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 30.0)),
            const SizedBox(width: 5),
            if (widget.readOnly) const Icon(Icons.business, size: 30),
            if (!widget.readOnly)
              const Icon(Icons.add_business_outlined, size: 30),
          ]),
          actions: widget.readOnly && widget.company.manager == widget.email
              ? <Widget>[
                  PopupMenuButton<CompanyOptions>(
                    tooltip:
                        AppLocalizations.of(context).translate('open_menu'),
                    onSelected: (CompanyOptions result) async {
                      if (result == CompanyOptions.consultBankData &&
                          widget.readOnly &&
                          widget.company.manager == widget.email) {
                        setState(() {
                          isLoading = true;
                        });
                        final DocumentReference ref = getIt<FirebaseFirestore>()
                            .collection('bank')
                            .doc(widget.company.bankAccountId);
                        final DocumentSnapshot documentSnapshot =
                            await ref.get();
                        final BankAccount bankAccount =
                            BankAccount.fromJson(documentSnapshot.data());
                        Navigator.push(
                            context,
                            MaterialPageRoute<BankPage>(
                                builder: (BuildContext context) => BankPage(
                                      bankAccount: bankAccount,
                                      readOnly: true,
                                    )));
                        setState(() {
                          isLoading = false;
                        });
                      }
                    },
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<CompanyOptions>>[
                      PopupMenuItem<CompanyOptions>(
                          value: CompanyOptions.consultBankData,
                          child: Text(AppLocalizations.of(context)
                              .translate('consult_bank_data')))
                    ],
                    offset: const Offset(0, 30),
                  )
                ]
              : null,
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
                        CompanyForm(
                          readOnly: widget.readOnly,
                          company: widget.company,
                          onSubmmitCompany:
                              (Company company, BankAccount bankAccount) async {
                            final String token =
                                await getIt<SignInService>().getRefreshToken();
                            final int statusCode = await getIt<CompanyService>()
                                .createCompany(
                                    company.copyWith(
                                        manager: widget.email,
                                        employees: <String>[widget.email]),
                                    bankAccount.copyWith(
                                      email: widget.email,
                                    ),
                                    token);
                            if (statusCode == 200) {
                              Navigator.popUntil(context,
                                  (Route<dynamic> route) => route.isFirst);
                              showSnackBar(
                                  AppLocalizations.of(context)
                                      .translate('successful_company_added'),
                                  Colors.greenAccent,
                                  context);
                            } else {
                              showSnackBar(
                                  AppLocalizations.of(context)
                                      .translate('unsuccessful_company_added'),
                                  Colors.redAccent,
                                  context);
                            }
                          },
                        ),
                      ]))));
  }
}
