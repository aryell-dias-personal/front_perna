import 'package:perna/constants/constants.dart';
import 'package:perna/pages/mainPage.dart';
import 'package:perna/services/signIn.dart';
import 'package:perna/store/actions.dart';
import 'package:perna/store/state.dart';
import 'package:perna/store/stores.dart';
import 'package:flutter/material.dart';
import 'package:perna/pages/initialPage.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:redux/redux.dart';

GoogleSignIn googleSignIn = GoogleSignIn(
  scopes: <String>[emailUserInfo],
);

void main() {
  runApp(new MyApp(store: store));
}

class MyApp extends StatelessWidget {
  final Store<StoreState> store;
  final SignInService signInService = new SignInService(googleSignIn: googleSignIn);

  MyApp({@required this.store}){
    signInService.silentLogin().then((user){
      if(user!=null){
        store.dispatch(LogIn(user));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return new StoreProvider<StoreState>(
        store: store,
        child:MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          backgroundColor: Colors.brown,
          primarySwatch: Colors.blue,
        ),
        home: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: StoreConnector<StoreState, bool>(
            converter: (store) {
              return store.state.logedIn;
            },
            builder: (context, logedIn) {
              return logedIn ? MainPage(onLogout: signInService.logOut) : InitialPage(signInService: signInService);
            }
          ),
          theme: ThemeData(
            primaryColor: Color(0xFF1c4966)
          )
        )
      )
    );
  }
}