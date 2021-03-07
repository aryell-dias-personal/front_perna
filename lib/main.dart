import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:perna/constants/constants.dart';
import 'package:perna/helpers/app_localizations.dart';
import 'package:perna/helpers/my_decoder.dart';
import 'package:perna/home.dart';
import 'package:perna/services/directions.dart';
import 'package:perna/services/driver.dart';
import 'package:perna/services/payments.dart';
import 'package:perna/services/sign_in.dart';
import 'package:perna/services/static_map.dart';
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
import 'package:get_it/get_it.dart';

GetIt getIt = GetIt.instance;

GoogleSignIn googleSignIn = GoogleSignIn(
  scopes: <String>[emailUserInfo],
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final Persistor<StoreState> persistor = Persistor<StoreState>(
    storage: FlutterStorage(),
    serializer: JsonSerializer<StoreState>(StoreState.fromJson),
  );

  final StoreState initialState = await persistor.load();
  
  FlavorConfig(
      name: 'DEVELOP',
      variables: <String, String>{
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

  FirebaseApp app;
  if(Firebase.apps.isEmpty) {
    app = await Firebase.initializeApp(
      name: FlavorConfig.instance.variables['appName'] as String,
      options: FirebaseOptions(
        appId: FlavorConfig.instance.variables['googleAppID'] as String,
        apiKey: FlavorConfig.instance.variables['apiKey'] as String,
        projectId: FlavorConfig.instance.variables['projectID'] as String,
        messagingSenderId: 
          FlavorConfig.instance.variables['gcmSenderID'] as String,
      )
    );
  } else {
    app = Firebase.apps.first;
  }
  final FirebaseFirestore firestore = FirebaseFirestore.instanceFor(app: app);
  final FirebaseAuth firebaseAuth = FirebaseAuth.instanceFor(app: app);
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  final NotificationSettings settings = 
  await firebaseMessaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  String messagingToken;
  if(settings.authorizationStatus == AuthorizationStatus.authorized) {
    messagingToken = await firebaseMessaging.getToken();
      await firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true, badge: true, sound: true,
      );
  }

  // NOTE: declarado serviços
  final MyDecoder myDecoder = MyDecoder();
  getIt.registerSingleton<DirectionsService>(DirectionsService());
  getIt.registerSingleton<UserService>(
    UserService(
      myDecoder: myDecoder
    ),
  );
  getIt.registerSingleton<DriverService>(
    DriverService(
      myDecoder: myDecoder
    ),
  );
  getIt.registerSingleton<PaymentsService>(
    PaymentsService(
      myDecoder: myDecoder
    ),
  );
  getIt.registerSingleton<SignInService>(
    SignInService(
      firebaseAuth: firebaseAuth,
      googleSignIn: googleSignIn,
      myDecoder: myDecoder
    ),
  );
  getIt.registerSingleton<StaticMapService>(StaticMapService());
  getIt.registerSingleton<FirebaseFirestore>(firestore);

  final Store<StoreState> store = Store<StoreState>(
    reduce, initialState: initialState.copyWith(messagingToken: messagingToken),
    middleware: <dynamic Function(Store<StoreState>, dynamic, dynamic Function(dynamic))>[persistor.createMiddleware()]
  );
  runApp(MyApp(store: store, firebaseMessaging: firebaseMessaging));
}

class MyApp extends StatelessWidget {
  const MyApp({@required this.store, @required this.firebaseMessaging});

  final Store<StoreState> store;
  final FirebaseMessaging firebaseMessaging;


  @override
  Widget build(BuildContext context) {
    const Color mainLightColor = Color(0xFF1c4966);
    const Color mainDarkColor = Color(0xFFf5feff);
    SystemChrome.setPreferredOrientations(<DeviceOrientation>[
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return StoreProvider<StoreState>(
      store: store,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Builder(
          builder: (BuildContext context) => Scaffold(
            backgroundColor: Theme.of(context).backgroundColor, 
            body: Home(
              firebaseMessaging: firebaseMessaging
            )
          )
        ),
        supportedLocales: const <Locale>[
          Locale('en', 'US'),
          Locale('pt', 'BR'),
        ],
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        localeResolutionCallback: (Locale locale, Iterable<Locale> supportedLocales) {
          for (final Locale supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale.languageCode &&
                supportedLocale.countryCode == locale.countryCode) {
              return supportedLocale;
            }
          }
          return supportedLocales.first;
        },
        theme: ThemeData(
          brightness: Brightness.light,
          textTheme: const TextTheme(
            bodyText2: TextStyle(color: mainLightColor)
          ),
          iconTheme: const IconThemeData(
            color: mainLightColor
          ),
          disabledColor: mainLightColor.withAlpha(66),
          primaryColor: mainLightColor,
          accentColor: mainLightColor.withAlpha(66),
          fontFamily: 'ProductSans',
          backgroundColor: Colors.white
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          textTheme: const TextTheme(
            bodyText2: TextStyle(color: mainDarkColor)
          ),
          iconTheme: const IconThemeData(
            color: mainDarkColor
          ),
          disabledColor: mainDarkColor.withAlpha(66),
          primaryColor: mainDarkColor,
          accentColor: mainDarkColor.withAlpha(66),
          fontFamily: 'ProductSans',
          backgroundColor: const Color(0xFF2b2b2b)
        ),
      )
    );
  }
}