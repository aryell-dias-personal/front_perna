import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TitledValueWidget extends StatelessWidget {
  final String title;
  final String value;
  final double titleSize;
  final double valueSize;

  const TitledValueWidget({@required this.title, @required this.value, this.titleSize=14, this.valueSize=14});

  bool _isEmptyValue(){
    return RegExp(r'^ *$').hasMatch(this.value);
  }

  @override
  Widget build(BuildContext context) {
    return !this._isEmptyValue() ? RichText(
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: const TextStyle(
          color: Theme.of(context).textTheme.bodyText2.color, 
          fontFamily: 'ProductSans'
        ),
        children:  <TextSpan>[
          TextSpan(text: '$title:', style: const TextStyle(fontSize: titleSize, fontWeight: FontWeight.bold)),
          TextSpan(text: ' $value', style: const TextStyle(fontSize: valueSize)),
        ],
      ) 
      , maxLines: 2
    ) : SizedBox();
  }
}