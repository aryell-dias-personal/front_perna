import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:perna/constants/constants.dart';
import 'package:perna/helpers/appLocalizations.dart';
import 'package:perna/helpers/myDecoder.dart';
import 'package:perna/helpers/showSnackBar.dart';
import 'package:perna/home.dart';
import 'package:perna/services/driver.dart';
import 'package:perna/services/signIn.dart';
import 'package:perna/services/user.dart';
import 'package:perna/store/state.dart';
import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:redux_persist/redux_persist.dart';
import 'package:perna/store/reducers.dart';
import 'package:redux_persist_flutter/redux_persist_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_flavor/flutter_flavor.dart';

GoogleSignIn googleSignIn = GoogleSignIn(
  scopes: <String>[emailUserInfo],
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  final String messagingToken = await firebaseMessaging.getToken();

  final persistor = Persistor<StoreState>(
    storage: FlutterStorage(),
    serializer: JsonSerializer<StoreState>(StoreState.fromJson),
  );

  final initialState = await persistor.load();
  
  FlavorConfig(
      name: "DEVELOP",
      variables: {
        'paymentPublishableKey': 'pk_test_51IOaRiEHLjxuMcanAIUxWIvwpU90K6GWskTx0iGsHliV7LtxPKZBoBOfj1rfoRIzxt5Xp6EYw1ZFqTHwlnU6t1WL00VfoidTNJ',
        'appName': 'aryell-test',
        'projectID': 'aryell-test',
        'gcmSenderID': '376560728219',
        'baseUrl': 'https://us-east1-aryell-test.cloudfunctions.net/perna-app-dev-',
        'apiKey': 'AIzaSyC_d-ntsVtnwyO6VhG2qHmDA4pCyFYP0gY',
        'googleAppID': '1:376560728219:android:82633609a640175003ee3e',
        'merchantId': 'Test',
        'androidPayMode': 'test'
      },
  );

  final FirebaseApp app = await FirebaseApp.configure(
    name: FlavorConfig.instance.variables['appName'],
    options: FirebaseOptions(
      googleAppID: FlavorConfig.instance.variables['googleAppID'],
      apiKey: FlavorConfig.instance.variables['apiKey'],
      projectID: FlavorConfig.instance.variables['projectID'],
      gcmSenderID: FlavorConfig.instance.variables['gcmSenderID'],
    )
  );
  final Firestore firestore = Firestore(app: app);
  final FirebaseAuth firebaseAuth = FirebaseAuth.fromApp(app);

  MyDecoder myDecoder = MyDecoder();
  final store = new Store<StoreState>(
    reduce, initialState: initialState.copyWith(
      firestore: firestore, 
      messagingToken: messagingToken,
      userService: UserService(
        myDecoder: myDecoder
      ),
      driverService: DriverService(
        myDecoder: myDecoder
      ),
      signInService: SignInService(
        firebaseAuth: firebaseAuth,
        googleSignIn: googleSignIn,
        myDecoder: myDecoder
      )
    ),
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
    Color mainDarkColor = Color(0xFFf5feff);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return StoreProvider<StoreState>(
      store: store,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Builder(
          builder: (context) => Scaffold(
            key: scaffoldKey,
            backgroundColor: Theme.of(context).backgroundColor, 
            body: Home(
              firebaseMessaging: this.firebaseMessaging, 
              driverService: store.state.driverService,
              signInService: store.state.signInService,
            )
          )
        ),
        supportedLocales: [
          Locale('en', 'US'),
          Locale('pt', 'BR'),
        ],
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        localeResolutionCallback: (locale, supportedLocales) {
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale.languageCode &&
                supportedLocale.countryCode == locale.countryCode) {
              return supportedLocale;
            }
          }
          return supportedLocales.first;
        },
        theme: ThemeData(
          brightness: Brightness.light,
          textTheme: TextTheme(
            bodyText2: TextStyle(color: mainLightColor)
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
            bodyText2: TextStyle(color: mainDarkColor)
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