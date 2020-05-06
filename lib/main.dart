import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:perna/home.dart';
import 'package:perna/store/state.dart';
import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:redux_persist/redux_persist.dart';
import 'package:perna/store/reducers.dart';
import 'package:redux_persist_flutter/redux_persist_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();
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
  runApp(new MyApp(store: store, firebaseMessaging: firebaseMessaging));
}

class MyApp extends StatelessWidget {
  final Store<StoreState> store;
  final FirebaseMessaging firebaseMessaging;

  MyApp({@required this.store, @required this.firebaseMessaging});

  @override
  Widget build(BuildContext context) {
    Color mainLightColor = Color(0xFF1c4966);
    Color mainDarkColor = Color(0xFFb5f8ff);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return StoreProvider<StoreState>(
      store: store,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Home(firebaseMessaging: this.firebaseMessaging),
        theme: ThemeData(
          brightness: Brightness.light,
          textTheme: TextTheme(
            body1: TextStyle(color: mainLightColor)
          ),
          iconTheme: IconThemeData(
            color: mainLightColor
          ),
          primaryColor: mainLightColor,
          accentColor: mainLightColor.withAlpha(66),
          fontFamily: "ProductSans",
          backgroundColor: Colors.white
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          textTheme: TextTheme(
            body1: TextStyle(color: mainDarkColor)
          ),
          iconTheme: IconThemeData(
            color: mainDarkColor
          ),
          primaryColor: mainDarkColor,
          accentColor: mainDarkColor.withAlpha(66),
          fontFamily: "ProductSans",
          backgroundColor: Color(0xFF2b2b2b)
        ),
      )
    );
  }
}