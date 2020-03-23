import 'package:perna/services/signIn.dart';
import 'package:perna/store/actions.dart';
import 'package:perna/store/state.dart';
import 'package:flutter/material.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:toast/toast.dart';

class InitialPage extends StatelessWidget {

  final SignInService signInService;
  InitialPage({@required this.signInService});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AvatarGlow(
              endRadius: 90,
              duration: Duration(seconds: 2),
              glowColor: Colors.white24,
              repeat: true,
              repeatPauseDuration: Duration(seconds: 2),
              startDelay: Duration(seconds: 1),
              child: Material(
                  elevation: 8.0,
                  shape: CircleBorder(),
                  child: CircleAvatar(
                    backgroundColor: Colors.grey[100],
                    child: FlutterLogo(
                      size: 60.0,
                    ),
                    radius: 50.0,
                  )),
            ),
            SizedBox(
              height: 20.0,
            ),
            Text(
              'E aí?!',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 40.0,
                  color: Color(0xFFFFFFFF)),
            ),
            Text(
              'Bem vindo ao Perna!',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 35.0,
                  color: Color(0xFFFFFFFF)),
            ),
            SizedBox(
              height: 50.0,
            ),
            StoreConnector<StoreState, Function()>(
              converter: (store) {
                return () async {
                  GoogleSignInAccount user = await signInService.signIn();
                  if(user==null){
                    Toast.show(
                      "Não foi possivel reconhecer o usuário", context, 
                      backgroundColor: Colors.redAccent, 
                      duration: 3
                    );
                  } else {
                    store.dispatch(SignIn(user));
                  }
                };
              },
              builder: (context, onSignIn) {
                return RaisedButton(
                  child: Text(
                    'Primeira vez por aqui',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25.0,
                        color: Color(0xFF1c4966)),
                  ),
                  onPressed: onSignIn,
                  color: Color(0xEEFFFFFF),
                  padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                  splashColor: Color(0x441c4966),
                  shape: StadiumBorder()
                );
              } 
            ),
            SizedBox(
              height: 20.0,
            ),
            StoreConnector<StoreState, Future<Null> Function()>(
              converter: (store) {
                return () async {
                  GoogleSignInAccount user = await signInService.logIn();
                  if(user==null){
                    Toast.show(
                      "Não foi possivel reconhecer o usuário", context, 
                      backgroundColor: Colors.redAccent, 
                      duration: 3
                    );
                  } else {
                    store.dispatch(LogIn(user));
                  }
                };
              },
              builder: (context, onLogIn) {
                return RaisedButton(
                  child: Text(
                    'Já estive aqui',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25.0,
                        color: Colors.white),
                  ),
                  onPressed: onLogIn,
                  color: Color(0x881c4966),
                  padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                  splashColor: Color(0x44FFFFFF),
                  shape: StadiumBorder()
                );
              } 
            ),
          ],
        ),
      ),
      backgroundColor: Color(0xFF1c4966),
    );
  }
}
