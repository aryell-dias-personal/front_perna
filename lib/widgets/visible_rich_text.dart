import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class VisibleRichText extends StatelessWidget {
  final double fontSize;
  final Color textColor;
  final String text;

  const VisibleRichText({Key key, this.fontSize, this.text, this.textColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RichText(
      overflow: TextOverflow.visible,
      textAlign: TextAlign.center,
      text: TextSpan(
        style: const TextStyle(color: this.textColor, fontFamily: 'ProductSans', fontSize: this.fontSize),
        children:  <TextSpan>[
          TextSpan(text: this.text),
        ]
      ) 
      , maxLines: 1
    );
  }
}