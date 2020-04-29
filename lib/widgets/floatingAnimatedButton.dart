import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FloatingAnimatedButton extends StatelessWidget {
  final bool isCollapsed;
  final Function onPressed;
  final Widget icon;
  final String heroTag;
  final double bottom;
  final Color color;

  const FloatingAnimatedButton({Key key, this.heroTag, this.isCollapsed, this.onPressed, this.icon, this.color, this.bottom}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 15, bottom: this.bottom, right: 15),
      child: AnimatedAlign(
        duration: Duration(milliseconds: 200),
        alignment: isCollapsed? Alignment.bottomRight : Alignment.bottomLeft,
        child: Container(
          child: FloatingActionButton(
            heroTag: heroTag,
            backgroundColor: color,
            child: icon,
            onPressed: onPressed,
          ),
          padding: const EdgeInsets.all(1.0)
        )
      ),
    );
  }
}