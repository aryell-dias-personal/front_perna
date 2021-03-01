import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:loading/loading.dart';
import 'package:perna/helpers/appLocalizations.dart';
import 'package:perna/models/agent.dart';
import 'package:perna/models/askedPoint.dart';
import 'package:perna/pages/askedPointPage.dart';
import 'package:perna/pages/expedientPage.dart';
import 'package:perna/store/state.dart';
import 'package:intl/intl.dart';
import 'package:perna/widgets/titledValueWidget.dart';

class HistoryPage extends StatefulWidget {
  final String email;
  final Firestore firestore;

  HistoryPage({@required this.email, @required this.firestore});

  @override
  _HistoryPageState createState() => _HistoryPageState(email: this.email, firestore: this.firestore);
}

class _HistoryPageState extends State<HistoryPage> {
  final DateFormat format = DateFormat('dd/MM/yyyy HH:mm');
  final DateFormat formatDate = DateFormat('dd/MM/yyyy');
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

  String parseDuration(shiftStart, shiftEnd, date){
    int shift = shiftStart ?? shiftEnd; 
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(date.round()*1000);
    Duration duration = shift == null ? null : Duration(seconds: shift.round());
    if(dateTime != null && duration != null) {
      DateTime currTime = dateTime.add(duration);
      return format.format(currTime);
    }
    return formatDate.format(dateTime);
  }

  List getHistory(){
    List history = this.agents + this.askedPoints;
    history.sort((first, second){
      return -((first['askedEndAt'] ?? 0) - (second['askedEndAt'] ?? 0));
    });
    return history;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Theme.of(context).brightness,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children:<Widget>[
            Text(
              AppLocalizations.of(context).translate("history"),
              style: TextStyle(
                fontWeight: FontWeight.bold,  
                fontSize: 30.0
              )
            ),
            SizedBox(width: 5),
            Icon(Icons.timeline, size: 30),
          ]
        ),
        backgroundColor: Theme.of(context).backgroundColor,
        iconTheme: IconThemeData(
          color: Theme.of(context).primaryColor
        ),
        textTheme: TextTheme(
          headline6: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: 20,
            fontFamily: Theme.of(context).textTheme.headline6.fontFamily
          )
        ),
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: isLoadingAgents || isLoadingAskedPoints || !passedTime ? Center(
        child: Loading(indicator: BallPulseIndicator(), size: 100.0, color: Theme.of(context).primaryColor)
      ) : (
        (this.agents + this.askedPoints).isEmpty ?  Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Image.asset('assets/empty.png', scale: 2),
              Text(
                AppLocalizations.of(context).translate("nothing_here"), 
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20)
              ),
              Text(
                AppLocalizations.of(context).translate("no_operation"), 
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 17)
              )
            ],
          )
        ) : Builder(
          builder: (context) {
            return ListView.separated(
              itemCount: getHistory().length,
              separatorBuilder: (context, index) {
                return Divider();
              },
              itemBuilder: (context, index) {
                List history = getHistory();
                dynamic operation = history[index];
                return FlatButton(
                  onPressed: (){
                    Navigator.push(context, 
                      MaterialPageRoute(
                        builder: (context) => StoreConnector<StoreState, Map<String, dynamic>>(
                          converter: (store) => {
                            "userService": store.state.userService,
                            "driverService": store.state.driverService
                          },
                          builder: (context, resources) => operation['origin'] != null?
                            AskedPointPage(userService: resources['userService'], askedPoint: AskedPoint.fromJson(operation), readOnly: true, clear: (){}):
                            ExpedientPage(driverService: resources['driverService'], agent: Agent.fromJson(operation), readOnly: true, clear: (){})
                        )
                      )
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              TitledValueWidget(
                                title: AppLocalizations.of(context).translate(operation['origin'] == null ? "expedient" : "order"),
                                value: parseDuration(operation['askedStartAt'], operation['askedEndAt'], operation['date']),
                              ),
                              operation['origin'] == null ? TitledValueWidget(
                                title: AppLocalizations.of(context).translate("driver"),  
                                value: operation['email'] ?? ""
                              ) : SizedBox(),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              // TitledValueWidget(
                              //   title: "Valor",
                              //   value: "100,00 R\$"
                              // ),
                              Icon(
                                Icons.chevron_right,
                                color: Theme.of(context).primaryColor,
                              )
                            ]
                          )
                        ]
                      ),
                      SizedBox(height: 10),
                      Image.memory(base64Decode(operation['staticMap'])),
                      SizedBox(height: 10),
                    ],
                  )
                );
              },
            );
          },
        )
      )
    );
  }

}