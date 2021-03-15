import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:perna/helpers/app_localizations.dart';
import 'package:perna/widgets/form/company_form.dart';

class CompanyPage extends StatefulWidget {
  const CompanyPage({this.readOnly = false});

  final bool readOnly;

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
            Text(AppLocalizations.of(context).translate('provider'),
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 30.0)),
            const SizedBox(width: 5),
            if (widget.readOnly) const Icon(Icons.business, size: 30),
            if (!widget.readOnly)
              const Icon(Icons.add_business_outlined, size: 30),
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
                        CompanyForm(
                          readOnly: widget.readOnly,
                        ),
                      ]))));
  }
}
