import 'package:perna/widgets/bottomCard.dart';
import 'package:perna/widgets/cardHeader.dart';
import 'package:perna/widgets/timePicker.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

class UserWidget extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return BottomCard(
      height: 250,
      children: <Widget>[
        CardHeader(
          addFunction: (){},
          listFunction: (){},
          title: "Pedido",
        ),
        SizedBox(height: 10),
        TimePicker(labelText: "Partida"),
        SizedBox(height: 20),
        TimePicker(labelText: "Chegada")
      ]
    );
  }

}
