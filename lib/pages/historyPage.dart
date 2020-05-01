import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:loading/loading.dart';
import 'package:perna/models/agent.dart';
import 'package:perna/models/askedPoint.dart';
import 'package:perna/pages/pointDetailPage.dart';
import 'package:perna/widgets/titledValueWidget.dart';
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
    if(placePieces.length > 4){
      return "${placePieces[3]}, ${placePieces[4]}";
    } 
    return place;
  }

  List getHistory(){
    List history = this.agents + this.askedPoints;
    history.sort((first, second){
      return -(first['askedEndAt'] - second['askedEndAt']);
    });
    return history;
  }

  List<Widget> buildInfo(operation) {
    assert(operation['origin'] != null || operation['garage'] != null);
    return operation['origin'] != null ? buildAskedPoint(AskedPoint.fromJson(operation)) : buildAgent(Agent.fromJson(operation));
  }

  List<Widget> buildAskedPoint(AskedPoint askedPoint) {
    return <Widget>[
      SizedBox(height: 20),
      Text("PEDIDO", style: Theme.of(context).textTheme.body1),
      TitledValueWidget(title: "Nome", value: askedPoint.name),
      TitledValueWidget(title: "Hora da Partida", value: parseData(askedPoint.askedStartAt.toString())),
      TitledValueWidget(title: "Hora da Chegada", value: parseData(askedPoint.askedEndAt.toString())),
      TitledValueWidget(title: "Local da Partida", value: parsePlace(askedPoint.friendlyOrigin)),
      TitledValueWidget(title: "Local da Chegada", value: parsePlace(askedPoint.friendlyDestiny)),
      SizedBox(height: 20)
    ];
  }

  List<Widget> buildAgent(Agent agent) {
    return <Widget>[
      SizedBox(height: 20),
      Text("EXPEDIENTE", style: Theme.of(context).textTheme.body1),
      TitledValueWidget(title: "Nome", value: agent.name),
      TitledValueWidget(title: "Inicio do Expediente", value: parseData(agent.askedStartAt.toString())),
      TitledValueWidget(title: "Fim do Expediente", value: parseData(agent.askedEndAt.toString())),
      TitledValueWidget(title: "Garagem", value: parsePlace(agent.friendlyGarage)),
      TitledValueWidget(title: "Vagas", value: agent.places.toString()),
      SizedBox(height: 20)
    ];
  }

  List<TimelineModel> buildHistoryTiles() {
    return getHistory().map<TimelineModel>((operation){
      return TimelineModel(
        FlatButton(
          onPressed: (){
            Navigator.push(context, 
              MaterialPageRoute(
                builder: (context) => operation['origin'] != null?
                  PointDetailPage(askedPoint: AskedPoint.fromJson(operation)):
                  PointDetailPage(agent: Agent.fromJson(operation))
                )
            );
          }, 
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: buildInfo(operation)
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20)))
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