import 'package:perna/widgets/bottomCard.dart';
import 'package:perna/widgets/cardHeader.dart';
import 'package:perna/widgets/timePicker.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

class DriverWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _DriverWidget();
  }
}

class _DriverWidget extends StatefulWidget {
  _DriverWidget({ Key key}) : super(key: key);

  @override
  _DriverWidgetState createState() => _DriverWidgetState();
}

class _DriverWidgetState extends State<_DriverWidget> {
  int places = 0; 
  DateTime start, end;
  TextEditingController numberControler = new TextEditingController();

  void _showDialog() {
    showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return new NumberPickerDialog.integer(
          minValue: 0,
          maxValue: 1000,
          title: new Text("Pick a new price"),
          initialIntegerValue: places,
        );
      }
    ).then((value) {
      if (value != null) {
        setState((){
          places = value;
          numberControler.text = value.toString();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BottomCard(
      height: 330,
      children: <Widget>[
        CardHeader(
          addFunction: (){},
          listFunction: (){},
          title: "Expediente",
        ),
        SizedBox(height: 10),
        TimePicker(labelText: 'Início'),
        SizedBox(height: 20),
        TimePicker(labelText: 'Fim'),
        SizedBox(height: 20),
        TextField(
          onTap: _showDialog,
          controller: numberControler,
          readOnly: true,          
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: "Vagas",
          )
        )
      ]
    );
  }

}