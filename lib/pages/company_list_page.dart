import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:perna/helpers/app_localizations.dart';
import 'package:perna/pages/company_page.dart';

class CompanyListPage extends StatefulWidget {
  const CompanyListPage({this.email});

  final String email;

  @override
  _CompanyListPageState createState() => _CompanyListPageState();
}

class _CompanyListPageState extends State<CompanyListPage> {
  bool isLoading = false;

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
        body: isLoading
            ? Center(
                child: SpinKitDoubleBounce(
                    size: 100.0, color: Theme.of(context).primaryColor))
            : Builder(builder: (BuildContext context) {
                return ListView.separated(
                    itemCount: 0,
                    separatorBuilder: (BuildContext context, int index) {
                      return const Divider();
                    },
                    itemBuilder: (BuildContext context, int index) {
                      return const SizedBox();
                    });
              }),
        floatingActionButton: FloatingActionButton(
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
                color: Theme.of(context).backgroundColor)));
  }
}
