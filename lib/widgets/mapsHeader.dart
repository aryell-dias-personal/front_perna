import 'package:perna/constants/constants.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';


class MapsHeader extends StatelessWidget {
  final Function menuBuilder;
  final Function onSelected;
  final String photoUrl;

  MapsHeader({@required this.menuBuilder, @required this.onSelected, @required this.photoUrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 30, 0, 0),
      child: Stack(children: <Widget>[
        Align(
            alignment: Alignment.topLeft,
            child: Container(
              child: CircleAvatar(
                backgroundImage: NetworkImage(photoUrl),
                backgroundColor: Colors.transparent,
              ),
              padding: const EdgeInsets.all(1.0), // borde width
              decoration: new BoxDecoration(
                color: Colors.transparent, // border color
                shape: BoxShape.circle,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black12,
                    offset: Offset(1.0, 6.0),
                    blurRadius: 60
                  ),
                ],
              )
            )
          ),
          Align(
            alignment: Alignment.topRight,
            child: PopupMenuButton<MenuOption>(
              onSelected: onSelected, 
              itemBuilder: menuBuilder
            )
          )
        ]
      )
    );
  }
}
