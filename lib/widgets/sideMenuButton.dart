import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SideMenuButton extends StatelessWidget {
  final Function onPressed;
  final String text;
  final IconData icon;
  final Color textColor;
  
  SideMenuButton({@required this.text, @required this.onPressed, @required this.icon, @required this.textColor});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children:<Widget>[
          Text(this.text, style: TextStyle(color: textColor, fontSize: 18)),
          SizedBox(width: 2),
          Icon(icon, color: textColor, size: 18)
        ]
      ),
      onPressed: this.onPressed,
      style: ButtonStyle(
        shape: MaterialStateProperty.all(StadiumBorder()),
        backgroundColor: MaterialStateProperty.all(Colors.transparent)
      )
    );
  }
}