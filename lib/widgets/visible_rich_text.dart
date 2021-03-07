import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class VisibleRichText extends StatelessWidget {
  const VisibleRichText({Key key, this.fontSize, this.text, this.textColor}) : super(key: key);

  final double fontSize;
  final Color textColor;
  final String text;

  @override
  Widget build(BuildContext context) {
    return RichText(
      overflow: TextOverflow.visible,
      textAlign: TextAlign.center,
      text: TextSpan(
        style: TextStyle(color: textColor, fontFamily: 'ProductSans', fontSize: fontSize),
        children:  <TextSpan>[
          TextSpan(text: text),
        ]
      ) 
      , maxLines: 1
    );
  }
}