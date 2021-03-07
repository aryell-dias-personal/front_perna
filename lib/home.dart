import 'dart:convert';
import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:perna/constants/notification.dart';
import 'package:perna/helpers/app_localizations.dart';
import 'package:perna/helpers/show_snack_bar.dart';
import 'package:perna/models/agent.dart';
import 'package:perna/pages/expedient_page.dart';
import 'package:perna/services/driver.dart';
import 'package:perna/services/signIn.dart';
import 'package:perna/store/state.dart';
import 'package:perna/pages/main_page.dart';
import 'package:perna/pages/no_connection_page.dart';
import 'package:perna/pages/initial_page.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:connectivity/connectivity.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as timezone;
import 'package:timezone/timezone.dart' as timezone;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = 
  FlutterLocalNotificationsPlugin();

Future<dynamic> onMessage(RemoteMessage message) async {
  const JsonEncoder enc = JsonEncoder();
  final Random rand = Random();
  final AndroidNotificationDetails androidPlatformChannelSpecifics = 
    AndroidNotificationDetails(updateDotAndRouteChannelId, 
      updateDotAndRouteChannelName, updateDotAndRouteChannelDescription
    );
  final NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics
  );
  await flutterLocalNotificationsPlugin.show(
    rand.nextInt(1000), 
    message.notification.title, 
    message.notification.body, 
    platformChannelSpecifics,
    payload: enc.convert(<String, dynamic>{
      'data': message.data
    })
  );
}

class Home extends StatefulWidget {
  const Home({
    @required this.firebaseMessaging, 
    @required this.driverService, 
    @required this.signInService, 
    Key key
  }) : super(key: key);

  final FirebaseMessaging firebaseMessaging;
  final DriverService driverService;
  final SignInService signInService;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isConnected = true;

  Future<dynamic> askNewAgentHandler(RemoteMessage message) async {
    const JsonEncoder enc = JsonEncoder();
    final NavigatorState navigatorState = Navigator.of(context);
    final Agent agent = Agent.fromJson(
      enc.convert(message.data['agent'])
    );
    await navigatorState.push( 
      MaterialPageRoute<Scaffold>(
        builder: (BuildContext context) => Scaffold(
          body: ExpedientPage(agent: agent, readOnly: true, clear: (){}, 
            getRefreshToken: widget.signInService.getRefreshToken,
            driverService: widget.driverService,
            accept: () async { 
              await answerNewAgentHandler(agent, accepted: true); 
            },
            deny: () async { 
              await answerNewAgentHandler(agent, accepted: false); 
            }
          )
        )
      )
    );
  }

  Future<dynamic> answerNewAgentHandler(Agent agent, { bool accepted }) async {
    if(accepted){
      final String token =  await widget.signInService.getRefreshToken();
      final int statusCodeNewAgent = await widget.driverService.postNewAgent(
        agent, 
        token
      );
      if(statusCodeNewAgent !=200){
        showSnackBar(
          AppLocalizations.of(context).translateFormat(
            'accept_not_possible', 
            <String>[agent.fromEmail]
          ),
          Colors.redAccent, context
        );
        return;
      }
    }
    final int statusCodeAnswer = await widget.driverService.answerNewAgent(
      agent.fromEmail, 
      agent.email, 
      accepted: accepted
    );
    if(statusCodeAnswer == 200){
      final String answer = AppLocalizations.of(context).translate(
        accepted? 'accepted' : 'denied'
      );
      showSnackBar(
        AppLocalizations.of(context).translateFormat(
          'answer_order', 
          <String>[answer, agent.fromEmail]
        ), 
        Colors.greenAccent, context
      );
    } else {
      showSnackBar(
        AppLocalizations.of(context).translateFormat(
          'not_answer_order',  
          <String>[agent.fromEmail]
        ), 
        Colors.redAccent, context
      );
    }
    Navigator.of(context).popUntil((Route<dynamic> route) => route.isFirst);
  }

  Future scheduleMessage(RemoteMessage message) async {
    const JsonEncoder enc = JsonEncoder();
    final Random rand = Random();
    final int time = double.parse(message.data['time']).round();
    final String content = AppLocalizations.of(context).translate(
      message.data['type'] == expedientType ?  
        'reminder_content_expedient' : 
        'reminder_content_travel');
    timezone.initializeTimeZones();
    final String currentTimeZone = 
      await FlutterNativeTimezone.getLocalTimezone();
    timezone.setLocalLocation(timezone.getLocation(currentTimeZone));
    timezone.TZDateTime date = timezone.TZDateTime.fromMicrosecondsSinceEpoch(timezone.local, time*1000).subtract(Duration(hours: 1));
    AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      remeberYouOfDotAndRouteChannelId, remeberYouOfDotAndRouteChannelName, remeberYouOfDotAndRouteChannelDescription
    );
    DateFormat format = DateFormat('HH:mm');
    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics
    );
    await flutterLocalNotificationsPlugin.zonedSchedule(
      rand.nextInt(1000), 
      AppLocalizations.of(context).translate('remind'), 
      AppLocalizations.of(context).translateFormat('reminder_message', [format.format(date), content]), 
      date, platformChannelSpecifics, payload: enc.convert({ 'data': null }), androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime
    );
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
    AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('ic_launcher');
    InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid
    );
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (String payload) async { 
        JsonDecoder dec = JsonDecoder();
        RemoteMessage message = RemoteMessage.fromMap(dec.convert(payload)); 
        await onLaunch(message);
      }
    );

    FirebaseMessaging.onMessage.listen(onMessage);
    // HACK: não precisa configurar, já que o launch já tá por aqui
    // FirebaseMessaging.onBackgroundMessage(onMessage);
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
      builder: (BuildContext context, resources) {
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