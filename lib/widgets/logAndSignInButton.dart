import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LogAndSignInButton extends StatelessWidget {
  final Function onPressed;
  final String text;
  final bool isSignIn;
  
  LogAndSignInButton({@required this.text, @required this.onPressed, this.isSignIn = false});

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      child: Text(
        this.text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 25.0,
          color: !this.isSignIn? Theme.of(context).primaryColor : Theme.of(context).backgroundColor
        ),
      ),
      onPressed: this.onPressed,
      color: !this.isSignIn? Theme.of(context).backgroundColor.withOpacity(1): Theme.of(context).primaryColor,
      padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
      shape: StadiumBorder()
    );
  }
}