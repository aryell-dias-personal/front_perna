import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LogAndSignInButton extends StatelessWidget {
  const LogAndSignInButton(
      {@required this.text, @required this.onPressed, this.isSignIn = false});

  final Function() onPressed;
  final String text;
  final bool isSignIn;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(!isSignIn
              ? Theme.of(context).backgroundColor.withOpacity(1)
              : Theme.of(context).primaryColor),
          padding: MaterialStateProperty.all(
              const EdgeInsets.fromLTRB(20, 10, 20, 10)),
          shape: MaterialStateProperty.all(const StadiumBorder())),
      child: Text(
        text,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 25.0,
            color: !isSignIn
                ? Theme.of(context).primaryColor
                : Theme.of(context).backgroundColor),
      ),
    );
  }
}
