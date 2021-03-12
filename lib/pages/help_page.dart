import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:perna/models/help_item.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({required this.helpItem});

  final HelpItem helpItem;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double screemWidth = size.width;
    return Scaffold(
        appBar: AppBar(
          brightness: Theme.of(context).brightness,
          centerTitle: true,
          title: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                    RichText(
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                          style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyText2!.color,
                              fontFamily: 'ProductSans'),
                          children: <TextSpan>[
                            TextSpan(
                                text: helpItem.smallTitle,
                                style: const TextStyle(
                                    fontSize: 30, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        maxLines: 2),
                  ] +
                  (helpItem.iconData == null
                      ? <Widget>[]
                      : <Widget>[
                          const SizedBox(width: 5),
                          Icon(helpItem.iconData, size: 30),
                        ])),
          backgroundColor: Theme.of(context).backgroundColor,
          iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
          textTheme: TextTheme(
              headline6: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 20,
                  fontFamily:
                      Theme.of(context).textTheme.headline6!.fontFamily)),
        ),
        backgroundColor: Theme.of(context).backgroundColor,
        body: Builder(builder: (BuildContext context) {
          return ListView.separated(
              itemCount: (helpItem.subItems.length) +
                  (helpItem.content == '' ? 0 : 1),
              separatorBuilder: (BuildContext context, int index) {
                return const Divider();
              },
              itemBuilder: (BuildContext context, int index) {
                if (index == 0) {
                  return Padding(
                      padding: const EdgeInsets.all(10),
                      child: Center(
                          child: Column(children: <Widget>[
                        Text(
                          helpItem.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          helpItem.content,
                          textAlign: TextAlign.justify,
                          style: const TextStyle(fontSize: 14),
                        )
                      ])));
                }
                final HelpItem subHelpItem = helpItem.subItems[index - 1];
                return TextButton(
                  style: ButtonStyle(
                      overlayColor: MaterialStateProperty.all(
                          Theme.of(context).splashColor)),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute<HelpPage>(
                            builder: (BuildContext context) =>
                                HelpPage(helpItem: subHelpItem)));
                  },
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        SizedBox(
                          width: screemWidth - 56,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                subHelpItem.smallTitle,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor),
                              ),
                              RichText(
                                  overflow: TextOverflow.ellipsis,
                                  text: TextSpan(
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyText2!
                                            .color,
                                        fontFamily: 'ProductSans'),
                                    children: <TextSpan>[
                                      TextSpan(
                                          text: subHelpItem.title,
                                          style: const TextStyle(fontSize: 12)),
                                    ],
                                  ),
                                  maxLines: 2),
                            ],
                          ),
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              Icon(
                                Icons.chevron_right,
                                color: Theme.of(context).primaryColor,
                              )
                            ])
                      ]),
                );
              });
        }));
  }
}
