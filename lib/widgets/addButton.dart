import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:perna/helpers/appLocalizations.dart';

class AddButton extends StatelessWidget {
  final bool readOnly;
  final bool addAndcontinue;
  final Function() onPressed;

  const AddButton({Key key, this.readOnly, this.addAndcontinue = false, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: this.readOnly? null : onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children:<Widget>[
          Text(
            AppLocalizations.of(context).translate(this.addAndcontinue ? "continue" :"add"), 
            style: TextStyle(color: Theme.of(context).backgroundColor, fontSize: 18)
          ),
          Icon(this.addAndcontinue ? Icons.chevron_right_rounded : Icons.add, color: Theme.of(context).backgroundColor, size: 20)
        ]
      ),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Theme.of(context).primaryColor),
        shape: MaterialStateProperty.all(StadiumBorder()),
      )
    );
  }
}