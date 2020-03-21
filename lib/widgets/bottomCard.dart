import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

class BottomCard extends StatelessWidget {
  final List<Widget> children;
  final double height;

  BottomCard({@required this.children, @required this.height});

  BoxDecoration _getDecoration(){
    return new BoxDecoration(
      color: Colors.white,
      boxShadow: <BoxShadow>[
        BoxShadow(
          color: Colors.black,
          offset: Offset(1.0, 6.0),
          blurRadius: 10),
      ],
      borderRadius: new BorderRadius.only(
        topLeft: const Radius.circular(15.0),
        topRight: const Radius.circular(15.0)
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'BottomCard',
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: height,
          decoration: _getDecoration(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: Column(
              children: children
            )
          )
        )
      )
    );
  }
}
