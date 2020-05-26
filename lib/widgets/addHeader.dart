import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:perna/helpers/appLocalizations.dart';

class AddHeader extends StatelessWidget {
  final bool readOnly;
  final String name;
  final bool showMenu;
  final IconData icon;
  final Function itemBuilder;
  final Function onSelected;
  final Widget child;

  const AddHeader({this.readOnly, this.showMenu, this.icon, this.itemBuilder, this.onSelected, this.name, this.child});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.max,
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children:<Widget>[ 
      Row(
        mainAxisSize: MainAxisSize.min,
        children:<Widget>[
          Text(
            "${this.readOnly? "" : AppLocalizations.of(context).translate("new")}$name",
            style: TextStyle(
              fontWeight: FontWeight.bold,  
              fontSize: 30.0
            )
          ),
          SizedBox(width: 5),
          Icon(this.icon, size: 30)
        ]
      )
    ] + (this.showMenu ? [
      child
    ]: [])
  );
}