
import 'package:flutter/material.dart';

void showSnackBar(String text, BuildContext context, Color backgroundColor){
  Scaffold.of(context).showSnackBar(
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