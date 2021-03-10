import 'package:flutter/cupertino.dart';

class HelpItem {
  HelpItem(
      {this.subItems,
      this.smallTitle,
      this.title,
      this.content,
      this.iconData});

  List<HelpItem> subItems;
  String title;
  String smallTitle;
  String content;
  IconData iconData;
}
