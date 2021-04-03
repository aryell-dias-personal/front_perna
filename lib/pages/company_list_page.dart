import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:perna/helpers/app_localizations.dart';
import 'package:perna/helpers/show_snack_bar.dart';
import 'package:perna/main.dart';
import 'package:perna/models/bank_account.dart';
import 'package:perna/models/company.dart';
import 'package:perna/models/user.dart';
import 'package:perna/pages/bank_page.dart';
import 'package:perna/pages/company_page.dart';
import 'package:perna/pages/user_list_page.dart';
import 'package:perna/widgets/company/company_widget.dart';
import 'package:perna/services/company.dart';
import 'package:perna/services/sign_in.dart';

class CompanyListPage extends StatefulWidget {
  const CompanyListPage({this.email});

  final String email;

  @override
  _CompanyListPageState createState() => _CompanyListPageState();
}

class _CompanyListPageState extends State<CompanyListPage> {
  int selectedIndex;
  Timer timer;
  String userToken;
  bool isLoading = false;
  List<Company> companys;
  bool passedTime = false;
  StreamSubscription<QuerySnapshot> companysListener;

  StreamSubscription<QuerySnapshot> _initcompanysListener() {
    return getIt<FirebaseFirestore>()
        .collection('company')
        .where('employees', arrayContains: widget.email)
        .snapshots()
        .listen((QuerySnapshot companysSnapshot) {
      setState(() {
        companys = companysSnapshot.docs.map((QueryDocumentSnapshot company) {
          return Company.fromJson(company.data()).copyWith(id: company.id);
        }).toList();
        isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
    companysListener.cancel();
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      timer = Timer(const Duration(seconds: 2), () {
        setState(() {
          passedTime = true;
        });
      });
      isLoading = true;
      getIt<SignInService>().getRefreshToken().then((String token) {
        setState(() {
          userToken = token;
        });
      });
      companysListener = _initcompanysListener();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          brightness: Theme.of(context).brightness,
          centerTitle: true,
          title: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
            Text(AppLocalizations.of(context).translate('provider'),
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 30.0)),
            const SizedBox(width: 5),
            const Icon(Icons.business, size: 30),
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
        body: isLoading || !passedTime || userToken == null
            ? Center(
                child: SpinKitDoubleBounce(
                    size: 100.0, color: Theme.of(context).primaryColor))
            : (companys.isEmpty
                ? Center(
                    child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Image.asset('assets/no_company.png', scale: 2),
                      Text(AppLocalizations.of(context).translate('no_company'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 20)),
                      Text(
                        AppLocalizations.of(context)
                            .translate('no_company_description'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 17),
                      )
                    ],
                  ))
                : Builder(builder: (BuildContext context) {
                    return ListView.separated(
                        itemCount: companys.length,
                        separatorBuilder: (BuildContext context, int index) {
                          return const Divider();
                        },
                        itemBuilder: (BuildContext context, int index) {
                          final Company company = companys[index];
                          return ComapanyWidget(
                            company: company,
                            top: company == companys.first ? 15 : 5,
                            onLongPress: companys[index].manager == widget.email
                                ? () {
                                    setState(() {
                                      if (index == selectedIndex) {
                                        selectedIndex = null;
                                      } else {
                                        selectedIndex = index;
                                      }
                                    });
                                  }
                                : null,
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute<CompanyPage>(
                                      builder: (BuildContext context) =>
                                          CompanyPage(
                                              readOnly: true,
                                              company: company,
                                              email: widget.email)));
                            },
                            selected: index == selectedIndex,
                          );
                        });
                  })),
        floatingActionButton: Builder(
            builder: (BuildContext context) => isLoading || !passedTime
                ? const SizedBox()
                : (selectedIndex == null ||
                        companys[selectedIndex].manager != widget.email
                    ? FloatingActionButton(
                        heroTag: '3',
                        backgroundColor: Theme.of(context).primaryColor,
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute<CompanyPage>(
                                  builder: (BuildContext context) =>
                                      CompanyPage(email: widget.email)));
                        },
                        tooltip: AppLocalizations.of(context).translate('addProvider'),
                        child: Icon(Icons.add_business_outlined,
                            color: Theme.of(context).backgroundColor))
                    : SpeedDial(
                        icon: Icons.edit_outlined,
                        marginEnd: 14,
                        iconTheme: IconThemeData(
                          color: Theme.of(context).backgroundColor,
                          opacity: 1,
                        ),
                        heroTag: '3',
                        backgroundColor: Theme.of(context).primaryColor,
                        children: <SpeedDialChild>[
                          SpeedDialChild(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute<BankPage>(
                                      builder: (BuildContext context) =>
                                          BankPage(
                                            onSubmmitBankAccount: (BankAccount
                                                bankAccount) async {
                                              final int statusCode =
                                                  await getIt<CompanyService>()
                                                      .changeBank(
                                                          companys[
                                                                  selectedIndex]
                                                              .id,
                                                          bankAccount.copyWith(
                                                            email: widget.email,
                                                          ),
                                                          userToken);
                                              if (statusCode == 200) {
                                                showSnackBar(
                                                    AppLocalizations.of(context)
                                                        .translate(
                                                            'successful_company_edit'),
                                                    Colors.greenAccent,
                                                    context);
                                                Navigator.of(context).pop();
                                              } else {
                                                showSnackBar(
                                                    AppLocalizations.of(context)
                                                        .translate(
                                                            'unsuccessful_company_edit'),
                                                    Colors.redAccent,
                                                    context);
                                              }
                                            },
                                          )));
                            },
                            child: Icon(Icons.account_balance,
                                color: Theme.of(context).backgroundColor),
                            label: AppLocalizations.of(context)
                                .translate('change_bank_account'),
                            backgroundColor: Colors.blueAccent,
                          ),
                          SpeedDialChild(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute<UserListPage>(
                                      builder: (BuildContext context) =>
                                          UserListPage(
                                            companyId: companys[selectedIndex].id,
                                            title: AppLocalizations.of(context)
                                                .translate('manage_employees'),
                                            email: widget.email,
                                            keys: companys[selectedIndex]
                                                .employees,
                                            onSubmmitChanges:
                                                (List<User> users) async {
                                              final Company currCompany =
                                                  companys[selectedIndex];
                                              final int statusCode = await getIt<
                                                      CompanyService>()
                                                  .updateCompany(
                                                      currCompany.copyWith(
                                                          employees: users
                                                              .map((User
                                                                      user) =>
                                                                  user.email)
                                                              .toList()),
                                                      userToken);
                                              if (statusCode == 200) {
                                                showSnackBar(
                                                    AppLocalizations.of(context)
                                                        .translate(
                                                            'successful_company_edit'),
                                                    Colors.greenAccent,
                                                    context);
                                              } else {
                                                showSnackBar(
                                                    AppLocalizations.of(context)
                                                        .translate(
                                                            'unsuccessful_company_edit'),
                                                    Colors.redAccent,
                                                    context);
                                              }
                                            },
                                          )));
                            },
                            child: Icon(Icons.person_add_alt_1_outlined,
                                color: Theme.of(context).backgroundColor),
                            label: AppLocalizations.of(context)
                                .translate('manage_employees'),
                            backgroundColor: Colors.amberAccent,
                          ),
                          SpeedDialChild(
                              onTap: () async {
                                setState(() {
                                  isLoading = true;
                                });
                                final int statusCode =
                                    await getIt<CompanyService>().deleteCompany(
                                        companys[selectedIndex].id, userToken);
                                if (statusCode == 200) {
                                  setState(() {
                                    selectedIndex = null;
                                    isLoading = false;
                                  });
                                  showSnackBar(
                                      AppLocalizations.of(context).translate(
                                          'successful_company_deleted'),
                                      Colors.greenAccent,
                                      context);
                                } else {
                                  setState(() {
                                    selectedIndex = null;
                                    isLoading = false;
                                  });
                                  showSnackBar(
                                      AppLocalizations.of(context).translate(
                                          'unsuccessful_company_deleted'),
                                      Colors.redAccent,
                                      context);
                                }
                              },
                              child: Icon(Icons.delete_outline,
                                  color: Theme.of(context).backgroundColor),
                              label: AppLocalizations.of(context)
                                  .translate('delete_company'),
                              backgroundColor: Colors.redAccent)
                        ],
                        tooltip: AppLocalizations.of(context)
                            .translate('edit_company'),
                      ))));
  }
}
