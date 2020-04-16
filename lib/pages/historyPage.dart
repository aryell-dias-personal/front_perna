import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:loading/loading.dart';
import 'package:timeline_list/timeline.dart';
import 'package:timeline_list/timeline_model.dart';

class HistoryPage extends StatefulWidget {
  final String email;
  final Firestore firestore;

  HistoryPage({@required this.email, @required this.firestore});

  @override
  _HistoryPageState createState() => _HistoryPageState(email: this.email, firestore: this.firestore);
}

class _HistoryPageState extends State<HistoryPage> {
  final Firestore firestore;
  final String email;

  List agents;
  StreamSubscription<QuerySnapshot> agentsListener;
  bool isLoadingAgents = false;

  List askedPoints;
  StreamSubscription<QuerySnapshot> askedPointsListener;
  bool isLoadingAskedPoints = false;

  Timer timer;
  bool passedTime = false;

  _HistoryPageState({@required this.email, @required this.firestore});

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
    agentsListener.cancel();
    askedPointsListener.cancel();
  }

  StreamSubscription<QuerySnapshot> initAgentsListner(){
    return firestore.collection("agent").where('email', isEqualTo: email)
      .snapshots().listen((QuerySnapshot agentsSnapshot){
        setState(() {
          this.agents = agentsSnapshot.documents.map((agent){
            return agent.data;
          }).toList();
          this.isLoadingAgents = false;
        });
    });
  }

  StreamSubscription<QuerySnapshot> initAskedPointsListener(){
    return firestore.collection("askedPoint").where('email', isEqualTo: email)
      .snapshots().listen((QuerySnapshot askedPointsSnapshot){
        setState(() {
          this.askedPoints = askedPointsSnapshot.documents.map((askedPoint){
            return askedPoint.data;
          }).toList();
          this.isLoadingAskedPoints = false;
        });
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      this.timer = Timer(Duration(seconds: 2), (){
        setState(() {
          passedTime = true;
        });
      });
      this.isLoadingAskedPoints = true;
      this.isLoadingAgents = true;
      agentsListener = this.initAgentsListner();
      askedPointsListener = this.initAskedPointsListener();
    });
  }

  RichText buildRichText(String title, String value) {
    return RichText(
      overflow: TextOverflow.ellipsis,
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

  List getHistory(){
    List history = this.agents + this.askedPoints;
    history.sort((first, second){
      return first['endAt'] - second['endAt'];
    });
    return history;
  }

  List<TimelineModel> buildHistoryTiles() {
    return getHistory().map<TimelineModel>((operation){
      List<Widget> info = [
        SizedBox(height: 20),
        Text(operation['origin'] != null? "PEDIDO": "EXPEDIENTE"),
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
      info.add(SizedBox(height: 20));
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
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoadingAgents || isLoadingAskedPoints || !passedTime ? Center(
        child: Loading(indicator: BallPulseIndicator(), size: 100.0, color: Theme.of(context).primaryColor)
      ) : Timeline(
        position: TimelinePosition.Left,
        children: this.buildHistoryTiles()
      )
    );
  }

}