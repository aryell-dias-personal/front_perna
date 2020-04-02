import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:perna/widgets/expedientWidget.dart';

class AddNewExpedientPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Stack(
        children: <Widget>[
          ExpedientWidget(driverMarkers: Set())
        ] 
      )
    );
  }
}