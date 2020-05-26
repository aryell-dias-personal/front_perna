import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:perna/helpers/appLocalizations.dart';
import 'package:perna/models/agent.dart';
import 'package:perna/pages/expedientPage.dart';
import 'package:perna/widgets/titledValueWidget.dart';

class PinInfo extends StatelessWidget {
  final bool visible;
  final Agent agent;

  const PinInfo({Key key, this.visible, this.agent}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: Duration(milliseconds: 200),
      left: 0,
      right: 0,
      bottom: this.visible? 0 : -100,
      child: Padding(
        padding: EdgeInsets.all(15),
        child:  Material(
          color: Theme.of(context).backgroundColor,
          clipBehavior: Clip.antiAlias,
          borderRadius: BorderRadius.all(Radius.circular(50)),
          elevation: 5,
          child: InkWell(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(
                  builder: (context) => ExpedientPage(agent: this.agent, readOnly: true, clear: (){})
                )
              );
            },
            child: Container(
              padding: EdgeInsets.only(left: 30, right: 10, top: 10, bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          width: 260,
                          child: TitledValueWidget(
                            title: AppLocalizations.of(context).translate("expedient_name"), 
                            value: (this.agent?.name ?? ""),
                            titleSize: 14,
                            valueSize: 14,
                          ),
                        ),
                        Container(
                          width: 260,
                          child: TitledValueWidget(
                            title: AppLocalizations.of(context).translate("driver_email"),  
                            value: (this.agent?.email ?? ""),
                            titleSize: 14,
                            valueSize: 14,
                          ),
                        ),
                        TitledValueWidget(
                          title: AppLocalizations.of(context).translate("seats_number"),  
                          value: "${this.agent?.places ?? ""}",
                          titleSize: 14,
                          valueSize: 14,
                        ),
                      ]
                    ),
                  CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Padding(
                      padding: EdgeInsets.all(10), 
                      child: Image.asset('icons/car_small.png') 
                    ),
                    radius: 30,
                  )
                ],
              )
            )
          )
        )
      )
    );
  }
}