// import 'dart:math';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:perna/constants/notification.dart';
import 'package:perna/helpers/appLocalizations.dart';
import 'package:perna/helpers/showSnackBar.dart';
import 'package:perna/models/agent.dart';
import 'package:perna/pages/expedientPage.dart';
import 'package:perna/services/driver.dart';
import 'package:perna/services/signIn.dart';
import 'package:perna/store/state.dart';
import 'package:perna/pages/mainPage.dart';
import 'package:perna/pages/noConnectionPage.dart';
import 'package:perna/pages/initialPage.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:connectivity/connectivity.dart';
// import 'package:intl/intl.dart';
import 'dart:convert';

// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future onMessage(RemoteMessage message) async {
  // JsonEncoder enc = JsonEncoder();
  // Random rand = Random();
  // AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
  //   updateDotAndRouteChannelId, updateDotAndRouteChannelName, updateDotAndRouteChannelDescription
  // );
  // NotificationDetails platformChannelSpecifics = NotificationDetails(
  //   androidPlatformChannelSpecifics, null);
  // await flutterLocalNotificationsPlugin.show(
  //   rand.nextInt(1000), message["notification"]["title"], message["notification"]["body"], platformChannelSpecifics,
  //   payload: enc.convert(message)
  // );
}

class Home extends StatefulWidget {
  final FirebaseMessaging firebaseMessaging;
  final DriverService driverService;
  final SignInService signInService;

  Home({
    @required this.firebaseMessaging, 
    @required this.driverService, 
    @required this.signInService, 
    Key key
  }) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isConnected = true;

  Future askNewAgentHandler(RemoteMessage message) async {
    NavigatorState navigatorState = Navigator.of(context);
    Agent agent = Agent.fromJson(JsonDecoder().convert(message.data['agent']));
    await navigatorState.push( 
      MaterialPageRoute(
        builder: (context) => Scaffold(
          body: ExpedientPage(agent: agent, readOnly: true, clear: (){}, 
            getRefreshToken: widget.signInService.getRefreshToken,
            driverService: widget.driverService,
            accept: () async { await answerNewAgentHandler(agent, true); },
            deny: () async { await answerNewAgentHandler(agent, false); }
          )
        )
      )
    );
  }

  Future answerNewAgentHandler(Agent agent, bool accepted) async {
    if(accepted){
      String token =  await widget.signInService.getRefreshToken();
      int statusCodeNewAgent = await widget.driverService.postNewAgent(agent, token);
      if(statusCodeNewAgent !=200){
        showSnackBar(
          AppLocalizations.of(context).translateFormat("accept_not_possible", [agent.fromEmail]),
          Colors.redAccent, context
        );
        return;
      }
    }
    int statusCodeAnswer = await widget.driverService.answerNewAgent(agent.fromEmail, agent.email, accepted);
    if(statusCodeAnswer == 200){
      String answer = AppLocalizations.of(context).translate(accepted? "accepted" : "denied");
      showSnackBar(
        AppLocalizations.of(context).translateFormat("answer_order", [answer, agent.fromEmail]), 
        Colors.greenAccent, context
      );
    } else {
      showSnackBar(
        AppLocalizations.of(context).translateFormat("not_answer_order", [agent.fromEmail]), 
        Colors.redAccent, context
      );
    }
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future scheduleMessage(RemoteMessage message) async {
    // Random rand = Random();
    // int time = double.parse(message.data['time']).round();
    // String content = AppLocalizations.of(context).translate(
    //   message.data['type'] == expedientType ? "reminder_content_expedient" : "reminder_content_travel");
    // DateTime date = DateTime.fromMillisecondsSinceEpoch(time*1000).subtract(Duration(hours: 1));
    // AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
    //   remeberYouOfDotAndRouteChannelId, remeberYouOfDotAndRouteChannelName, remeberYouOfDotAndRouteChannelDescription
    // );
    // DateFormat format = DateFormat('HH:mm');
    // NotificationDetails platformChannelSpecifics = NotificationDetails(
    //   androidPlatformChannelSpecifics, null);
    // await flutterLocalNotificationsPlugin.schedule(
    //   rand.nextInt(1000), 
    //   AppLocalizations.of(context).translate("remind"), 
    //   AppLocalizations.of(context).translateFormat("reminder_message", [format.format(date), content]), 
    //   date, platformChannelSpecifics, payload: 'remember', androidAllowWhileIdle: true
    // );
  }
  
  Future onLaunch(RemoteMessage message) async {
    if(message.data != null){
      if(message.data['time'] != null && message.data['type'] != null){
        await scheduleMessage(message);
      } else if(message.data['agent'] != null){
        await askNewAgentHandler(message);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('ic_launcher');
    // InitializationSettings initializationSettings = InitializationSettings(initializationSettingsAndroid, null);
    // flutterLocalNotificationsPlugin.initialize(initializationSettings,
    //   onSelectNotification: (String payload) async { 
    //     if(payload != "remember"){
    //       JsonDecoder dec = JsonDecoder();
    //       Map<String, dynamic> message = dec.convert(payload); 
    //       await onLaunch(message);
    //     }
    //   }
    // );

    FirebaseMessaging.onMessage.listen(onMessage);
    FirebaseMessaging.onBackgroundMessage(onMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(onLaunch);
  
    Connectivity().onConnectivityChanged.listen((ConnectivityResult connection){
      setState(() {
        isConnected = connection == ConnectivityResult.mobile || connection == ConnectivityResult.wifi;
      });
    });

  }

  @override
  Widget build(BuildContext context) {
    return !isConnected ? NoConnectionPage() : 
      StoreConnector<StoreState, Map<String, dynamic>>(
      converter: (store) {
        return {
          'logedIn': store.state.logedIn,
          'messagingToken': store.state.messagingToken,
          'email': store.state.user?.email,
          'firestore': store.state.firestore
        };
      },
      builder: (context, resources) {
        if(resources['logedIn'] == null || !resources['logedIn']){
          return InitialPage(
            signInService: widget.signInService, 
            messagingToken: resources['messagingToken']
          );
        } else {
          return MainPage(
            getRefreshToken: widget.signInService.getRefreshToken, 
            onLogout: widget.signInService.logOut, 
            email: resources['email'], 
            firestore: resources['firestore']
          );
        }
      }
    );
  }
}