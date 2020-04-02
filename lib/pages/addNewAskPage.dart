import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:perna/widgets/askWidget.dart';

class AddNewAskPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Stack(
        children: <Widget>[
          AskWidget(userMarkers: Set())
        ] 
      )
    );
  }
}