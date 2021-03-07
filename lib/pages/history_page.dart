import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:perna/helpers/app_localizations.dart';
import 'package:perna/helpers/credit_card.dart';
import 'package:perna/main.dart';
import 'package:perna/models/agent.dart';
import 'package:perna/models/asked_point.dart';
import 'package:perna/pages/asked_point_page.dart';
import 'package:perna/pages/expedient_page.dart';
import 'package:intl/intl.dart';
import 'package:perna/widgets/titled_value_widget.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({@required this.email});
  
  final String email;

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final DateFormat format = DateFormat('dd/MM/yyyy HH:mm');
  final DateFormat formatDate = DateFormat('dd/MM/yyyy');

  bool isLoadingAskedPoints = false;
  bool isLoadingAgents = false;
  bool passedTime = false;

  StreamSubscription<QuerySnapshot> askedPointsListener;
  StreamSubscription<QuerySnapshot> agentsListener;
  List<dynamic> askedPoints;
  List<dynamic> agents;
  Timer timer;

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
    agentsListener.cancel();
    askedPointsListener.cancel();
  }

  StreamSubscription<QuerySnapshot> initAgentsListner(){
    return getIt<FirebaseFirestore>().collection('agent')
      .where('email', isEqualTo: widget.email)
      .snapshots().listen((QuerySnapshot agentsSnapshot){
        setState(() {
          agents = agentsSnapshot.docs.map((QueryDocumentSnapshot agent){
            return agent.data();
          }).toList();
          isLoadingAgents = false;
        });
    });
  }

  StreamSubscription<QuerySnapshot> initAskedPointsListener(){
    return getIt<FirebaseFirestore>().collection('askedPoint')
      .where('email', isEqualTo: widget.email)
      .snapshots().listen((QuerySnapshot askedPointsSnapshot){
        setState(() {
          askedPoints = askedPointsSnapshot.docs.map(
            (QueryDocumentSnapshot askedPoint){
              return askedPoint.data();
            }
          ).toList();
          isLoadingAskedPoints = false;
        });
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      timer = Timer(const Duration(seconds: 2), (){
        setState(() {
          passedTime = true;
        });
      });
      isLoadingAskedPoints = true;
      isLoadingAgents = true;
      agentsListener = initAgentsListner();
      askedPointsListener = initAskedPointsListener();
    });
  }

  String parseDuration(dynamic shiftStart, dynamic shiftEnd, dynamic date){
    final int shiftStartInt = shiftStart is int ? shiftStart: (shiftStart as double)?.round();
    final int shiftEndInt = shiftEnd is int ? shiftEnd: (shiftEnd as double)?.round();
    final int dateInt = date is int ? date: (date as double).round();
    final int shift = shiftStartInt ?? shiftEndInt; 
    final DateTime dateTime = 
      DateTime.fromMillisecondsSinceEpoch(dateInt*1000);
    final Duration duration = shift == null 
      ? null : Duration(seconds: shift);
    if(dateTime != null && duration != null) {
      final DateTime currTime = dateTime.add(duration);
      return format.format(currTime);
    }
    return formatDate.format(dateTime);
  }

  List<dynamic> getHistory(){
    final List<dynamic> history = agents + askedPoints;
    history.sort((dynamic first, dynamic second){
      final dynamic firstTime = first['askedEndAt'] ?? 0;
      final dynamic secondTime = second['askedEndAt'] ?? 0;
      final int firstTimeInt = firstTime is int ? firstTime: (firstTime as double).round();
      final int secondTimeInt = secondTime is int ? secondTime: (secondTime as double).round();
      return secondTimeInt - firstTimeInt;
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
              AppLocalizations.of(context).translate('history'),
              style: const TextStyle(
                fontWeight: FontWeight.bold,  
                fontSize: 30.0
              )
            ),
            const SizedBox(width: 5),
            const Icon(Icons.timeline, size: 30),
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
        child: SpinKitDoubleBounce(
          size: 100.0, 
          color: Theme.of(context).primaryColor
        )
      ) : (
        (agents + askedPoints).isEmpty ?  Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Image.asset('assets/empty.png', scale: 2),
              Text(
                AppLocalizations.of(context).translate('nothing_here'), 
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20)
              ),
              Text(
                AppLocalizations.of(context).translate('no_operation'), 
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 17)
              )
            ],
          )
        ) : Builder(
          builder: (BuildContext context) {
            return ListView.separated(
              itemCount: getHistory().length,
              separatorBuilder: (BuildContext context, int index) {
                return const Divider();
              },
              itemBuilder: (BuildContext context, int index) {
                final List<dynamic> history = getHistory();
                final dynamic operation = history[index];
                return TextButton(
                  style: ButtonStyle(
                    overlayColor: MaterialStateProperty.all(
                      Theme.of(context).splashColor
                    )
                  ),
                  onPressed: (){
                    Navigator.push(context, 
                      MaterialPageRoute<Widget>(
                        builder: (BuildContext context) => 
                          operation['origin'] != null?
                          AskedPointPage(
                            askedPoint: AskedPoint.fromJson(
                              operation as Map<String, dynamic>), 
                            readOnly: true, 
                            clear: (){}
                          ):
                          ExpedientPage(
                            agent: Agent.fromJson(
                              operation as Map<String, dynamic>), 
                            readOnly: true, 
                            clear: (){}
                          )
                      )
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              TitledValueWidget(
                                title: 
                                  AppLocalizations.of(context).translate(
                                    operation['origin'] == null ? 
                                      'expedient' : 'order'),
                                value: parseDuration(
                                  operation['askedStartAt'],
                                  operation['askedEndAt'], 
                                  operation['date']
                                ),
                              ),
                              if(operation['origin'] == null) TitledValueWidget(
                                title: AppLocalizations.of(context)
                                  .translate('driver'),  
                                value: operation['email'] as String ?? ''
                              )
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              if(operation['amount'] != null) TitledValueWidget(
                                title: AppLocalizations.of(context)
                                  .translate('price'),
                                value: formatAmount(
                                  operation['amount'] as int, 
                                  operation['currency'] as String, 
                                  AppLocalizations.of(context).locale
                                )
                              ),
                              Icon(
                                Icons.chevron_right,
                                color: Theme.of(context).primaryColor,
                              )
                            ]
                          )
                        ]
                      ),
                      const SizedBox(height: 10),
                      Image.memory(
                        base64Decode(operation['staticMap'] as String)),
                      const SizedBox(height: 10),
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