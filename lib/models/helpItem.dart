
import 'package:flutter/cupertino.dart';

class HelpItem {
  List<HelpItem> subItems;
  String title;
  String smallTitle;
  String content;
  IconData iconData; 

  HelpItem({
    this.subItems,
    this.smallTitle,
    this.title,
    this.content,
    this.iconData
  });
}