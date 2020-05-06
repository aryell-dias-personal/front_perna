import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ActionButtons extends StatelessWidget {
  final Function() accept;
  final Function() deny;

  const ActionButtons({Key key, this.accept, this.deny}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        RaisedButton(
          onPressed: this.accept,
          child: Text("Aceitar", style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).backgroundColor
          )),
          color: Theme.of(context).primaryColor,
          shape: StadiumBorder()
        ),
        RaisedButton(
          onPressed: this.deny,
          child: Text("Negar", style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor
          )),
          color: Theme.of(context).backgroundColor,
          shape: StadiumBorder(),
        )
      ],
    );
  }
}