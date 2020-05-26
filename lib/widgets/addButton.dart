import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:perna/helpers/appLocalizations.dart';

class AddButton extends StatelessWidget {
  final bool readOnly;
  final Function() onPressed;

  const AddButton({Key key, this.readOnly, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      onPressed: this.readOnly? null : onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children:<Widget>[
          Text(AppLocalizations.of(context).translate("add"), style: TextStyle(color: Theme.of(context).backgroundColor, fontSize: 18)),
          Icon(Icons.add, color: Theme.of(context).backgroundColor, size: 20)
        ]
      ),
      color: Theme.of(context).primaryColor,
      shape: StadiumBorder(),
    );
  }
}