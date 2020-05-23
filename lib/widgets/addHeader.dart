import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AddHeader extends StatelessWidget {
  final bool readOnly;
  final String name;
  final bool showMenu;
  final IconData icon;
  final Function itemBuilder;
  final Function onSelected;
  final double spaceBetween;
  final Widget child;

  const AddHeader({this.readOnly, this.showMenu, this.icon, this.itemBuilder, this.onSelected, this.name, this.spaceBetween, this.child});

  @override
  Widget build(BuildContext context) => Row(
    children:<Widget>[
      Text(
        "${this.readOnly?"":"Novo "}$name",
        style: TextStyle(
          fontWeight: FontWeight.bold,  
          fontSize: 30.0
        )
      ),
      SizedBox(width: 5),
      Icon(this.icon, size: 30)
    ] + (this.showMenu ? [
      SizedBox(width: this.spaceBetween),
      child
    ]: [])
  );
}