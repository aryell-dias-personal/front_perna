import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:perna/constants/notification.dart';
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
import 'dart:convert';
import 'package:perna/constants/constants.dart';
import 'package:google_sign_in/google_sign_in.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

GoogleSignIn googleSignIn = GoogleSignIn(
  scopes: <String>[emailUserInfo],
);

Future onMessage(Map<String, dynamic> message) async {
  JsonEncoder enc = JsonEncoder();
  Random rand = Random();
  AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
    updateDotAndRouteChannelId, updateDotAndRouteChannelName, updateDotAndRouteChannelDescription
  );
  NotificationDetails platformChannelSpecifics = NotificationDetails(
    androidPlatformChannelSpecifics, null);
  await flutterLocalNotificationsPlugin.show(
    rand.nextInt(1000), message["notification"]["title"], message["notification"]["body"], platformChannelSpecifics,
    payload: enc.convert(message)
  );
}

class Home extends StatefulWidget {
  final FirebaseMessaging firebaseMessaging;
  final FirebaseAuth firebaseAuth;

  Home({@required this.firebaseMessaging, @required this.firebaseAuth, Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState(firebaseMessaging: this.firebaseMessaging, firebaseAuth: this.firebaseAuth);
}

class _HomeState extends State<Home> {
  final FirebaseMessaging firebaseMessaging;
  final FirebaseAuth firebaseAuth;
  final DriverService driverService = DriverService();

  bool isConnected = true;
  SignInService signInService;

  Future askNewAgentHandler(Map<String, dynamic> message) async {
    NavigatorState navigatorState = Navigator.of(context);
    Agent agent = Agent.fromJson(JsonDecoder().convert(message['data']['agent']));
    await navigatorState.push( 
      MaterialPageRoute(
        builder: (context) => Scaffold(
          body: ExpedientPage(agent: agent, readOnly: true, clear: (){}, 
            getRefreshToken: this.signInService.getRefreshToken,
            accept: () async { await answerNewAgentHandler(agent, true); },
            deny: () async { await answerNewAgentHandler(agent, false); }
          )
        )
      )
    );
  }

  Future answerNewAgentHandler(Agent agent, bool accepted) async {
    if(accepted){
      IdTokenResult idTokenResult =  await this.signInService.getRefreshToken();
      int statusCodeNewAgent = await driverService.postNewAgent(agent, idTokenResult.token);
      if(statusCodeNewAgent !=200){
        showSnackBar(
          AppLocalizations.of(context).translateFormat("accept_not_possible", [agent.fromEmail]),
          context, Colors.redAccent
        );
        return;
      }
    }
    int statusCodeAnswer = await driverService.answerNewAgent(agent.fromEmail, agent.email, accepted);
    if(statusCodeAnswer == 200){
      String answer = AppLocalizations.of(context).translate(accepted? "accepted" : "denied");
      showSnackBar(
        AppLocalizations.of(context).translateFormat("answer_order", [answer, agent.fromEmail]), 
        context, Colors.greenAccent
      );
    } else {
      showSnackBar(
        AppLocalizations.of(context).translateFormat("not_answer_order", [agent.fromEmail]), 
        context, Colors.redAccent
      );
    }
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future scheduleMessage(Map<String, dynamic> message) async {
    Random rand = Random();
    int time = double.parse(message['data']['time']).round();
    String content = AppLocalizations.of(context).translate(
      message['data']['type'] == expedientType ? "reminder_content_expedient" : "reminder_content_travel");
    DateTime date = DateTime.fromMillisecondsSinceEpoch(time*1000).subtract(Duration(hours: 1));
    AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      remeberYouOfDotAndRouteChannelId, remeberYouOfDotAndRouteChannelName, remeberYouOfDotAndRouteChannelDescription
    );
    NotificationDetails platformChannelSpecifics = NotificationDetails(
      androidPlatformChannelSpecifics, null);
    await flutterLocalNotificationsPlugin.schedule(
      rand.nextInt(1000), 
      AppLocalizations.of(context).translate("remind"), 
      AppLocalizations.of(context).translateFormat("reminder_message", [date.hour, date.minute, content]), 
      date, platformChannelSpecifics, payload: 'remember', androidAllowWhileIdle: true
    );
  }
  
  Future onLaunch(Map<String, dynamic> message) async {
    if(message.keys.contains("data")){
      if(message['data']['time'] != null && message['data']['type'] != null){
        await scheduleMessage(message);
      } else if(message['data']['agent'] != null){
        await askNewAgentHandler(message);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      this.signInService = new SignInService(googleSignIn: googleSignIn, firebaseAuth: this.firebaseAuth);
    });

    AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('ic_launcher');
    InitializationSettings initializationSettings = InitializationSettings(initializationSettingsAndroid, null);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (String payload) async { 
        if(payload != "remember"){
          JsonDecoder dec = JsonDecoder();
          Map<String, dynamic> message = dec.convert(payload); 
          await onLaunch(message);
        }
      }
    );

    this.firebaseMessaging.configure(
      onMessage: onMessage,
      onBackgroundMessage: onMessage, 
      onLaunch: onLaunch,
      onResume: onLaunch
    );
  
    Connectivity().onConnectivityChanged.listen((ConnectivityResult connection){
      setState(() {
        isConnected = connection == ConnectivityResult.mobile || connection == ConnectivityResult.wifi;
      });
    });

  }

  _HomeState({@required this.firebaseMessaging, @required this.firebaseAuth});

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
          return InitialPage(signInService: signInService, messagingToken: resources['messagingToken']);
        } else {
          return MainPage(getRefreshToken: signInService.getRefreshToken, onLogout: signInService.logOut, email: resources['email'], firestore: resources['firestore']);
        }
      }
    );
  }
}