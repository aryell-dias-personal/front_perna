import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FloatingAnimatedButton extends StatelessWidget {
  final Function onPressed;
  final Widget child;
  final String heroTag;
  final String description;
  final double bottom;
  final Color color;

  const FloatingAnimatedButton({Key key, this.heroTag, this.onPressed, this.child, this.color, this.bottom, this.description}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: Duration(milliseconds: 200),
      bottom: this.bottom, 
      right: 15,
      child: Container(
        child: FloatingActionButton(
          heroTag: heroTag,
          backgroundColor: color,
          child: child,
          tooltip: this.description,
          onPressed: onPressed,
        ),
        padding: const EdgeInsets.all(1.0)
      )
    );
  }
}