import 'package:perna/constants/constants.dart';
import 'package:perna/pages/mainPage.dart';
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

GoogleSignIn googleSignIn = GoogleSignIn(
  scopes: <String>[emailUserInfo],
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final persistor = Persistor<StoreState>(
    storage: FlutterStorage(),
    serializer: JsonSerializer<StoreState>(StoreState.fromJson),
  );

  final initialState = await persistor.load();
  
  final store = new Store<StoreState>(
    reduce, initialState: initialState,
    middleware: [persistor.createMiddleware()]
  );
  runApp(new MyApp(store: store));
}

class MyApp extends StatelessWidget {
  final Store<StoreState> store;
  final SignInService signInService = new SignInService(googleSignIn: googleSignIn);

  MyApp({@required this.store});

  @override
  Widget build(BuildContext context) {
    return new StoreProvider<StoreState>(
        store: store,
        child:MaterialApp(
        debugShowCheckedModeBanner: false,
        home: StoreConnector<StoreState, bool>(
          converter: (store) {
            return store.state.logedIn;
          },
          builder: (context, logedIn) {
            return logedIn != null && logedIn ? 
              StoreConnector<StoreState, String>(
                converter: (store) {
                  return store.state.user.email;
                },
                builder: (context, email) {
                  return MainPage(onLogout: signInService.logOut, email: email);
                }
              ) : InitialPage(signInService: signInService);
          }
        ),
        theme: ThemeData(
          primaryColor: Color(0xFF1c4966),
          accentColor: Color(0x881c4966),
          fontFamily: "ProductSans"
        )
      )
    );
  }
}