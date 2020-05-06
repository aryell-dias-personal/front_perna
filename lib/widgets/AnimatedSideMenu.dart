import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:perna/widgets/sideMenu.dart';

class AnimatedSideMenu extends StatelessWidget {
  final SideMenu sideMenu;
  final bool isOpen;

  const AnimatedSideMenu({Key key, this.sideMenu, this.isOpen}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double screemWidth = size.width; 
    return AnimatedPositioned(
      duration: Duration(milliseconds: 200),
      top: 0,
      bottom: 0,
      left: !isOpen ? -screemWidth/1.7 : 0,
      right: !isOpen ? screemWidth : screemWidth/1.7,
      child: Material(
        color: Theme.of(context).backgroundColor,
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.only(bottomRight: Radius.circular(30), topRight: Radius.circular(30)),
        elevation: 8,
        child: sideMenu
      ) 
    );
  }
}