import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:perna/constants/markdownHelp.dart';

class HelpPage extends StatelessWidget {

  final controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: SafeArea(
          child: Markdown(
            controller: controller,
            selectable: true,
            data: markdownHelp
          ),
        )
    );
  }
}