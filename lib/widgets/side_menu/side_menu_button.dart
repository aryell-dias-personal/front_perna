import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SideMenuButton extends StatelessWidget {
  const SideMenuButton(
      {@required this.text,
      @required this.onPressed,
      @required this.icon,
      @required this.textColor});

  final Function() onPressed;
  final String text;
  final IconData icon;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: ButtonStyle(
          overlayColor:
              MaterialStateProperty.all(Theme.of(context).splashColor),
          shape: MaterialStateProperty.all(const StadiumBorder()),
          backgroundColor: MaterialStateProperty.all(Colors.transparent)),
      onPressed: onPressed,
      child: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
        Text(text, style: TextStyle(color: textColor, fontSize: 18)),
        const SizedBox(width: 2),
        Icon(icon, color: textColor, size: 18)
      ]),
    );
  }
}
