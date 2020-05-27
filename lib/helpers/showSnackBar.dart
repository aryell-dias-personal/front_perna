
import 'package:flutter/material.dart';

final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

void showSnackBar(String text, Color backgroundColor, {BuildContext context, bool isGlobal=false}){
  (isGlobal ? scaffoldKey.currentState : Scaffold.of(context)).showSnackBar(
    SnackBar(
      backgroundColor: backgroundColor,
      duration: Duration(seconds: 3),
      content: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold
        ),
      )
    )
  );
}