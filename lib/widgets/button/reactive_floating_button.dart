import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:perna/helpers/app_localizations.dart';
import 'package:perna/widgets/button/floating_animated_button.dart';

class ReactiveFloatingButton extends StatelessWidget {
  const ReactiveFloatingButton(
      {required this.controller,
      required this.defaultFunction,
      required this.length,
      required this.addNewExpedient,
      required this.addNewAsk,
      this.bottom});

  final AnimationController controller;
  final Function() defaultFunction;
  final int length;
  final double? bottom;
  final Function() addNewExpedient;
  final Function() addNewAsk;

  @override
  Widget build(BuildContext context) {
    Color color = Theme.of(context).backgroundColor;
    Widget icon = AnimatedIcon(
        size: 30,
        icon: AnimatedIcons.menu_home,
        color: Theme.of(context).primaryColor,
        progress: controller);
    String description = AppLocalizations.of(context).translate('open_menu');
    Function() onPressed = defaultFunction;
    if (length != 0) {
      color = Colors.greenAccent;
      if (length == 1) {
        icon = Icon(Icons.work, color: Theme.of(context).backgroundColor);
        description = AppLocalizations.of(context).translate('add_expedient');
        onPressed = addNewExpedient;
      } else {
        icon =
            Icon(Icons.scatter_plot, color: Theme.of(context).backgroundColor);
        description = AppLocalizations.of(context).translate('add_order');
        onPressed = addNewAsk;
      }
    }
    return FloatingAnimatedButton(
      heroTag: '2',
      bottom: bottom,
      color: color,
      description: description,
      onPressed: onPressed,
      child: icon,
    );
  }
}
