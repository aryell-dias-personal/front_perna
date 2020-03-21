import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

class CardHeader extends StatelessWidget {
  final Function addFunction;
  final Function listFunction;
  final String title;

  CardHeader({@required this.addFunction, @required this.listFunction, @required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold, 
            fontSize: 20.0
          )
        ),
        Row(
          children: <Widget>[
            RaisedButton(
              onPressed: addFunction,
              color: Theme.of(context).primaryColor,
              child: Row(
                children: <Widget>[
                  Text('Adicionar', style: TextStyle(color: Colors.white)),
                  Icon(
                    Icons.add,
                    color: Colors.white,
                  )
                ]
              ),
              shape: StadiumBorder()
            ),
            SizedBox(width: 15),
            RaisedButton(
              onPressed: listFunction,
              color: Theme.of(context).primaryColor,
              child: Row(
                children: <Widget>[
                  Text(
                    'Listar', 
                    style: TextStyle(
                      color: Colors.white
                    )
                  ),
                  Icon(
                    Icons.list,
                    color: Colors.white,
                  )
                ]
              ),
              shape: StadiumBorder()
            )
          ]
        )
      ]
    );
  }
}
