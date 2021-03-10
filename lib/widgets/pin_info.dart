import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:perna/helpers/app_localizations.dart';
import 'package:perna/models/agent.dart';
import 'package:perna/pages/expedient_page.dart';
import 'package:perna/widgets/titled_value_widget.dart';

class PinInfo extends StatelessWidget {
  const PinInfo({Key key, this.visible, this.agent}) : super(key: key);

  final bool visible;
  final Agent agent;

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
        duration: const Duration(milliseconds: 200),
        left: 0,
        right: 0,
        bottom: visible ? 0 : -100,
        child: Padding(
            padding: const EdgeInsets.all(15),
            child: Material(
                color: Theme.of(context).backgroundColor,
                clipBehavior: Clip.antiAlias,
                borderRadius: const BorderRadius.all(Radius.circular(50)),
                elevation: 5,
                child: InkWell(
                    overlayColor: MaterialStateProperty.all(
                        Theme.of(context).splashColor),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute<ExpedientPage>(
                            builder: (BuildContext context) => ExpedientPage(
                                agent: agent, readOnly: true, clear: () {}),
                          ));
                    },
                    child: Container(
                        padding: const EdgeInsets.only(
                            left: 30, right: 10, top: 10, bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  SizedBox(
                                    width: 230,
                                    child: TitledValueWidget(
                                      title: AppLocalizations.of(context)
                                          .translate('driver'),
                                      value: agent?.email ?? '',
                                    ),
                                  ),
                                  TitledValueWidget(
                                    title: AppLocalizations.of(context)
                                        .translate('seats_number'),
                                    value: '${agent?.places ?? ''}',
                                  ),
                                ]),
                            CircleAvatar(
                              backgroundColor: Theme.of(context).primaryColor,
                              radius: 30,
                              child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Image.asset('icons/car_small.png')),
                            )
                          ],
                        ))))));
  }
}
