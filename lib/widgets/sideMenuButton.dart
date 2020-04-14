import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SideMenuButton extends StatelessWidget {
  final Function onPressed;
  final String text;
  final IconData icon;
  
  SideMenuButton({@required this.text, @required this.onPressed, @required this.icon});

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children:<Widget>[
          Text(this.text, style: TextStyle(color: Colors.white, fontSize: 18)),
          SizedBox(width: 2),
          Icon(icon, color: Colors.white, size: 18)
        ]
      ),
      onPressed: this.onPressed,
      color: Colors.transparent,
      shape: StadiumBorder(),
    );
  }
}