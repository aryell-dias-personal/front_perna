import 'package:flutter/cupertino.dart';

class HelpItem {
  HelpItem(
      {this.subItems = const <HelpItem>[],
      this.content = '',
      required this.smallTitle,
      required this.title,
      this.iconData});

  List<HelpItem> subItems;
  String title;
  String smallTitle;
  String content;
  IconData? iconData;
}
