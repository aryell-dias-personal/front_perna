import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:perna/helpers/app_localizations.dart';

class ActionButtons extends StatelessWidget {
  const ActionButtons({required this.accept, required this.deny});

  final Function() accept;
  final Function() deny;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        ElevatedButton(
          onPressed: accept,
          style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all(Theme.of(context).primaryColor),
              shape: MaterialStateProperty.all(const StadiumBorder())),
          child: Text(AppLocalizations.of(context).translate('accept'),
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).backgroundColor)),
        ),
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.all(Theme.of(context).backgroundColor),
            shape: MaterialStateProperty.all(const StadiumBorder()),
          ),
          onPressed: deny,
          child: Text(AppLocalizations.of(context).translate('deny'),
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor)),
        )
      ],
    );
  }
}
