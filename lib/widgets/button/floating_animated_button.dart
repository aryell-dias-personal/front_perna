import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FloatingAnimatedButton extends StatelessWidget {
  const FloatingAnimatedButton(
      {required this.heroTag,
      required this.child,
      this.onPressed,
      this.color,
      this.bottom,
      this.description});

  final Function()? onPressed;
  final Widget child;
  final String heroTag;
  final String? description;
  final double? bottom;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
        duration: const Duration(milliseconds: 200),
        bottom: bottom,
        right: 15,
        child: Container(
          padding: const EdgeInsets.all(1.0),
          child: FloatingActionButton(
            heroTag: heroTag,
            backgroundColor: color,
            onPressed: onPressed,
            tooltip: description,
            child: child,
          ),
        ));
  }
}
