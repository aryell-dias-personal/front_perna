import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LogAndSignInButton extends StatelessWidget {
  final Function onPressed;
  final String text;
  final bool isSignIn;
  
  LogAndSignInButton({@required this.text, @required this.onPressed, this.isSignIn = false});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: Text(
        this.text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 25.0,
          color: !this.isSignIn? Theme.of(context).primaryColor : Theme.of(context).backgroundColor
        ),
      ),
      onPressed: this.onPressed,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(!this.isSignIn? Theme.of(context).backgroundColor.withOpacity(1): Theme.of(context).primaryColor),
        padding: MaterialStateProperty.all(EdgeInsets.fromLTRB(20, 10, 20, 10)),
        shape: MaterialStateProperty.all(StadiumBorder())
      )
    );
  }
}