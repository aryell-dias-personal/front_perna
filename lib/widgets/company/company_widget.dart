import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:perna/helpers/app_localizations.dart';
import 'package:perna/models/company.dart';
import 'package:perna/widgets/text/titled_value_widget.dart';

class ComapanyWidget extends StatelessWidget {
  const ComapanyWidget(
      {this.company, this.top = 5, this.selected, this.onTap, this.onLongPress});

  final Company company;
  final double top;
  final bool selected;
  final Function() onTap;
  final Function() onLongPress;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(bottom: 5, top: top, left: 10, right: 10),
        child: Material(
            elevation: 3,
            color: Theme.of(context).backgroundColor,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10))),
            child: InkWell(
                overlayColor:
                    MaterialStateProperty.all(Theme.of(context).splashColor),
                onTap: onTap,
                onLongPress: onLongPress,
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(10)),
                            color: Theme.of(context).primaryColor),
                        child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                company.companyName,
                                style: TextStyle(
                                    fontSize: 21,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).backgroundColor),
                              ),
                              if (selected ?? false)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    Icon(Icons.check_circle_outline,
                                        color:
                                            Theme.of(context).backgroundColor),
                                    const SizedBox(width: 2),
                                    Text(
                                      AppLocalizations.of(context)
                                          .translate('selected'),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context)
                                              .backgroundColor),
                                    ),
                                  ],
                                )
                            ]),
                      ),
                      Container(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                TitledValueWidget(
                                  title: AppLocalizations.of(context)
                                      .translate('address'),
                                  maxLines: 1,
                                  value: company.address,
                                ),
                                const SizedBox(height: 10),
                                Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      TitledValueWidget(
                                        maxLines: 1,
                                        title: 'Id',
                                        value: company.companyNumber,
                                      ),
                                      const SizedBox(width: 10),
                                      TitledValueWidget(
                                        title: AppLocalizations.of(context)
                                            .translate('contact'),
                                        maxLines: 1,
                                        value: company.phone,
                                      ),
                                    ]),
                                const SizedBox(height: 10),
                                TitledValueWidget(
                                  title: AppLocalizations.of(context)
                                      .translate('manager_email'),
                                  maxLines: 1,
                                  value: company.manager,
                                ),
                              ]))
                    ]))));
  }
}
