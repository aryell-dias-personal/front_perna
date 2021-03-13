import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:perna/helpers/app_localizations.dart';

class AddButton extends StatelessWidget {
  const AddButton(
      {Key key, this.readOnly, this.addAndcontinue = false, this.onPressed})
      : super(key: key);

  final bool readOnly;
  final bool addAndcontinue;
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: readOnly ? null : onPressed,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(readOnly
            ? Theme.of(context).disabledColor
            : Theme.of(context).primaryColor),
        shape: MaterialStateProperty.all(const StadiumBorder()),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
        Text(
            AppLocalizations.of(context)
                .translate(addAndcontinue ? 'continue' : 'add'),
            style: TextStyle(
                color: Theme.of(context).backgroundColor, fontSize: 18)),
        Icon(addAndcontinue ? Icons.chevron_right_rounded : Icons.add,
            color: Theme.of(context).backgroundColor, size: 20)
      ]),
    );
  }
}
