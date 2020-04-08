import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:loading/loading.dart';
import 'package:perna/services/user.dart';
import 'package:timeline_list/timeline.dart';
import 'package:timeline_list/timeline_model.dart';

class HistoryPage extends StatefulWidget {
  final String email;

  HistoryPage({@required this.email});

  @override
  _HistoryPageState createState() => _HistoryPageState(email: this.email);
}

class _HistoryPageState extends State<HistoryPage> {
  bool isLoading = false;
  final UserService userService = UserService();
  final String email;
  List<dynamic> history;
  List<TimelineModel> historyTiles;

  _HistoryPageState({@required this.email});

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
    userService.getHistory(this.email).then((history){
      setState(() {
        this.history = history;
        this.historyTiles = buildHistoryTiles();
      });
    }).whenComplete((){
      setState(() {
        isLoading = false;
      });
    });
  }

  RichText buildRichText(String title, String value) {
    return RichText(
      text: TextSpan(
        style: TextStyle(color: Colors.black, fontFamily: "ProductSans"),
        children: <TextSpan>[
          TextSpan(text: "$title:", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold) ),
          TextSpan(text: " $value", style: TextStyle(fontSize: 20)),
        ]
      )
      , maxLines: 1
    );
  }

  String parseData(String date){
    String cuttedDate = date.substring(0,16);
    List<String> datePieces = cuttedDate.split(' ');
    return "${datePieces[0].split('-').reversed.join('/')} ${datePieces[1]}";
  }

  String parsePlace(String place){
    List<String> placePieces = place.split(',');
    return "${placePieces[3]}, ${placePieces[4]}";
  }

  List<TimelineModel> buildHistoryTiles() {
    return this.history?.map<TimelineModel>((operation){
      List<Widget> info = [
        SizedBox(height: 40),
        buildRichText("Nome", operation['name']),
        buildRichText("Hora da Partida", parseData(operation["friendlyStartAt"])),
        buildRichText("Hora da Chegada", parseData(operation["friendlyEndAt"]))
      ];
      info.addAll( operation['origin'] != null ? [ 
        buildRichText("Local da Partida", parsePlace(operation["friendlyOrigin"])),
        buildRichText("Local da Chegada", parsePlace(operation["friendlyDestiny"]))
      ] : [
        buildRichText("Garagem", parsePlace(operation["friendlyGarage"])),
        buildRichText("vagas", operation['places'].toString())
      ]);
      return TimelineModel(
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: info
        ),
        position: TimelineItemPosition.right,
        iconBackground: operation['origin'] != null ? Colors.redAccent : Colors.greenAccent,
        icon: Icon(operation['origin'] != null ? Icons.add_shopping_cart : Icons.directions_bus, color: Colors.white)
      );
    })?.toList() ?? <TimelineModel>[];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading ? Center(
        child: Loading(indicator: BallPulseIndicator(), size: 100.0, color: Theme.of(context).primaryColor)
      ) : Timeline(
        position: TimelinePosition.Left,
        children: this.historyTiles
      )
    );
  }

}