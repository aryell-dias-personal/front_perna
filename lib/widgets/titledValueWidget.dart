import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TitledValueWidget extends StatelessWidget {
  final String title;
  final String value;
  final double titleSize;
  final double valueSize;

  const TitledValueWidget({@required this.title, @required this.value, this.titleSize=14, this.valueSize=20});

  @override
  Widget build(BuildContext context) {
    return RichText(
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: TextStyle(color: Theme.of(context).textTheme.body1.color, fontFamily: "ProductSans"),
        children: <TextSpan>[
          TextSpan(text: "$title:", style: TextStyle(fontSize: titleSize, fontWeight: FontWeight.bold) ),
          TextSpan(text: " $value", style: TextStyle(fontSize: valueSize)),
        ]
      )
      , maxLines: 1
    );
  }
}