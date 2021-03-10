import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TitledValueWidget extends StatelessWidget {
  const TitledValueWidget(
      {@required this.title,
      @required this.value,
      this.titleSize = 14,
      this.valueSize = 14});

  final String title;
  final String value;
  final double titleSize;
  final double valueSize;

  bool _isEmptyValue() {
    return RegExp(r'^ *$').hasMatch(value);
  }

  @override
  Widget build(BuildContext context) {
    return !_isEmptyValue()
        ? RichText(
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              style: TextStyle(
                  color: Theme.of(context).textTheme.bodyText2.color,
                  fontFamily: 'ProductSans'),
              children: <TextSpan>[
                TextSpan(
                    text: '$title:',
                    style: TextStyle(
                        fontSize: titleSize, fontWeight: FontWeight.bold)),
                TextSpan(
                    text: ' $value', style: TextStyle(fontSize: valueSize)),
              ],
            ),
            maxLines: 2)
        : const SizedBox();
  }
}
