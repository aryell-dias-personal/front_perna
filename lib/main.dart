import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:perna/constants/constants.dart';
import 'package:perna/constants/notification.dart';
import 'package:perna/pages/mainPage.dart';
import 'package:perna/pages/noConnectionPage.dart';
import 'package:perna/services/signIn.dart';
import 'package:perna/store/state.dart';
import 'package:flutter/material.dart';
import 'package:perna/pages/initialPage.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:redux/redux.dart';
import 'package:redux_persist/redux_persist.dart';
import 'package:perna/store/reducers.dart';
import 'package:redux_persist_flutter/redux_persist_flutter.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

GoogleSignIn googleSignIn = GoogleSignIn(
  scopes: <String>[emailUserInfo],
);

Future scheduleMessage(Map<String, dynamic> message) async {
  if(message.keys.contains("data")){
    print("data: ${message['data']}");
    if(message['data']['time'] != null && message['data']['type'] != null){
      Random rand = Random();
      int time = double.parse(message['data']['time']).round();
      String content = message['data']['type'] == expedientType ? " expediente": "a viajem";
      DateTime date = DateTime.fromMillisecondsSinceEpoch(time*1000).subtract(Duration(hours: 1));
      AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
        remeberYouOfDotAndRouteChannelId, remeberYouOfDotAndRouteChannelName, remeberYouOfDotAndRouteChannelDescription
      );
      NotificationDetails platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, null);
      print("notificação marcada para: $date");
      await flutterLocalNotificationsPlugin.schedule(
        rand.nextInt(1000), "Passando só pra te lembrar", "De ${date.hour}:${date.minute} você tem um$content 😀", date, platformChannelSpecifics,
        payload: 'remember', androidAllowWhileIdle: true
      );
    }
  }
}

Future onMessage(Map<String, dynamic> message) async {
  JsonEncoder enc = JsonEncoder();
  Random rand = Random();
  print("on message $message");
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('ic_launcher');
  InitializationSettings initializationSettings = InitializationSettings(initializationSettingsAndroid, null);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
    onSelectNotification: (String payload) async { 
      if(payload != "remember"){
        JsonDecoder dec = JsonDecoder();
        Map<String, dynamic> message = dec.convert(payload); 
        await scheduleMessage(message);
      }
    }
  );

  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  firebaseMessaging.configure(
    onMessage: onMessage,
    onBackgroundMessage: onMessage, 
    onLaunch: scheduleMessage,
    onResume: scheduleMessage
  );

  final String messagingToken = await firebaseMessaging.getToken();

  final persistor = Persistor<StoreState>(
    storage: FlutterStorage(),
    serializer: JsonSerializer<StoreState>(StoreState.fromJson),
  );

  final initialState = await persistor.load();
  
  final FirebaseApp app = await FirebaseApp.configure(
    name: 'perna-app',
    options: const FirebaseOptions(
      googleAppID: '1:172739913177:android:38f4c6eb4f67cb674b25c8',
      apiKey: 'AIzaSyB8vF6jy-hpVosJ_LwwczTJTN55TimCEfQ',
      projectID: 'perna-app',
      gcmSenderID: '172739913177'
    )
  );
  final Firestore firestore = Firestore(app: app);

  final store = new Store<StoreState>(
    reduce, initialState: initialState.copyWith(firestore: firestore, messagingToken: messagingToken),
    middleware: [persistor.createMiddleware()]
  );
  runApp(new MyApp(store: store));
}

class MyApp extends StatelessWidget {
  final Store<StoreState> store;

  MyApp({@required this.store});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return _MyApp(store: this.store);
  }
}

class _MyApp extends StatefulWidget {  
  final Store<StoreState> store;

  _MyApp({@required this.store, Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState(store: this.store);
}

class _MyAppState extends State<_MyApp> {
  final Store<StoreState> store;
  final SignInService signInService = new SignInService(googleSignIn: googleSignIn);
  bool isConnected = true;

  @override
  void initState() {
    super.initState();
    Connectivity().onConnectivityChanged.listen((ConnectivityResult connection){
      setState(() {
        isConnected = connection == ConnectivityResult.mobile || connection == ConnectivityResult.wifi;
      });
    });
  }

  _MyAppState({@required this.store});

  @override
  Widget build(BuildContext context) {
    return StoreProvider<StoreState>(
      store: store,
      child:MaterialApp(
      debugShowCheckedModeBanner: false,
      home: !isConnected ? 
        NoConnectionPage() : 
        StoreConnector<StoreState, bool>(
          converter: (store) {
            return store.state.logedIn;
          },
          builder: (context, logedIn) {
            if(logedIn == null || !logedIn){
              return StoreConnector<StoreState, String>(
                converter: (store) => store.state.messagingToken,
                builder: (context, messagingToken) => InitialPage(signInService: signInService, messagingToken: messagingToken)
              );
            } else {
              return StoreConnector<StoreState, Map<String, dynamic>>(
                converter: (store) {
                  return {
                    'email': store.state.user.email,
                    'firestore': store.state.firestore
                  };
                },
                builder: (context, resources) {
                  return MainPage(onLogout: signInService.logOut, email: resources['email'], firestore: resources['firestore']);
                }
              );
            }
          }
        ),
        theme: ThemeData(
          textTheme: TextTheme(
            body1: TextStyle(color: Color(0xFF1c4966))
          ),
          iconTheme: IconThemeData(
            color: Color(0xFF1c4966)
          ),
          primaryColor: Color(0xFF1c4966),
          accentColor: Color(0x881c4966),
          fontFamily: "ProductSans"
        )
      )
    );
  }
}