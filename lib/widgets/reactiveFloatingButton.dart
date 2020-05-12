import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:perna/widgets/floatingAnimatedButton.dart';

class ReactiveFloatingButton extends StatelessWidget {
  final AnimationController controller;
  final Function() defaultFunction;
  final int length;
  final double bottom;
  final Function() addNewExpedient;
  final Function() addNewAsk;

  const ReactiveFloatingButton({Key key, this.controller, this.defaultFunction, this.length, this.addNewExpedient, this.addNewAsk, this.bottom}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    Color color = Theme.of(context).backgroundColor;
    Widget icon = AnimatedIcon(
      size: 30, icon: AnimatedIcons.menu_home,
      color: Theme.of(context).primaryColor,
      progress: this.controller
    );
    String description = "Abrir Menu";
    Function() onPressed =  this.defaultFunction;
    if(this.length != 0){
      color = Colors.greenAccent;
      if(this.length == 1){
        icon = Icon(Icons.work, color: Theme.of(context).backgroundColor);
        description = "Adicionar Expediente";
        onPressed = this.addNewExpedient;
      }else{
        icon = Icon(Icons.scatter_plot, color: Theme.of(context).backgroundColor);
        description = "Adicionar Pedido";
        onPressed = this.addNewAsk;
      }
    }
    return FloatingAnimatedButton(
      heroTag: "2",
      bottom: this.bottom,
      color: color,
      child: icon,
      description: description,
      onPressed: onPressed,
    );
  }
}