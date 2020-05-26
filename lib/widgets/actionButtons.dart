import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:perna/helpers/appLocalizations.dart';

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
          child: Text(AppLocalizations.of(context).translate("accept"), style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).backgroundColor
          )),
          color: Theme.of(context).primaryColor,
          shape: StadiumBorder()
        ),
        RaisedButton(
          onPressed: this.deny,
          child: Text(AppLocalizations.of(context).translate("deny"), style: TextStyle(
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