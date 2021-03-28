import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:perna/helpers/app_localizations.dart';
import 'package:perna/main.dart';
import 'package:perna/models/company.dart';
import 'package:perna/pages/company_page.dart';
import 'package:perna/widgets/company/company_widget.dart';

class CompanyListPage extends StatefulWidget {
  const CompanyListPage({this.email});

  final String email;

  @override
  _CompanyListPageState createState() => _CompanyListPageState();
}

class _CompanyListPageState extends State<CompanyListPage> {
  int selectedIndex;
  Timer timer;
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
          return Company.fromJson(company.data());
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
        body: isLoading || !passedTime
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
                            onTap: () {},
                            child: Icon(Icons.account_balance,
                                color: Theme.of(context).backgroundColor),
                            label: AppLocalizations.of(context)
                                .translate('change_bank_account'),
                            backgroundColor: Colors.blueAccent,
                          ),
                          SpeedDialChild(
                            onTap: () {},
                            child: Icon(Icons.person_add_alt_1_outlined,
                                color: Theme.of(context).backgroundColor),
                            label: AppLocalizations.of(context)
                                .translate('manage_employees'),
                            backgroundColor: Colors.amberAccent,
                          ),
                          SpeedDialChild(
                              onTap: () {},
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
