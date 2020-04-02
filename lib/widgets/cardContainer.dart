import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

class CardContainer extends StatelessWidget {
  final List<Widget> children;
  final double height;
  final Alignment alignment;

  CardContainer({@required this.children, @required this.height, @required this.alignment});

  BoxDecoration _getDecoration(){
    return new BoxDecoration(
      color: Colors.white,
      boxShadow: <BoxShadow>[
        BoxShadow(
          color: Colors.black,
          offset: Offset(1.0, 6.0),
          blurRadius: 10),
      ],
      borderRadius: new BorderRadius.all(
        const Radius.circular(15.0)
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: this.alignment,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        child: Container(
          height: height,
          decoration: _getDecoration(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, 
              children: children
            )
          )
        )
      )
    );
  }
}
