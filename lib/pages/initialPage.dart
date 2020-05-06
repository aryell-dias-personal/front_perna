import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:loading/loading.dart';
import 'package:perna/models/signInResponse.dart';
import 'package:perna/models/user.dart';
import 'package:perna/services/signIn.dart';
import 'package:perna/store/actions.dart';
import 'package:perna/store/state.dart';
import 'package:flutter/material.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:perna/widgets/logAndSignInButton.dart';
import 'package:toast/toast.dart';

enum SignLogin { sign, login}

class InitialPage extends StatefulWidget {
  final SignInService signInService;
  final String messagingToken;
  InitialPage({@required this.signInService, @required this.messagingToken});

  @override
  _InitialPageState createState() => _InitialPageState(signInService: signInService, messagingToken: messagingToken);
}

class _InitialPageState extends State<InitialPage> {
  bool isLoading = false;
  final String messagingToken;
  final SignInService signInService;
  _InitialPageState({@required this.signInService, @required this.messagingToken});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Center(
        child: isLoading ? Loading(indicator: BallPulseIndicator(), color: Theme.of(context).primaryColor, size: 100.0) : 
        StoreConnector<StoreState, Function(SignLogin)>(
          converter: (store) => (SignLogin choice) async {
            SignInResponse signInResponse = choice == SignLogin.sign ? 
              await signInService.signIn(this.messagingToken) : 
              await signInService.logIn(this.messagingToken);
            User user = signInResponse?.user;
            if(user==null){
              Toast.show(
                "Não foi possivel reconhecer o usuário", context, 
                backgroundColor: Colors.redAccent, 
                duration: 3
              );
            } else {
              store.dispatch(choice == SignLogin.sign? SignIn(user):LogIn(user));
            }
          },
          builder: (context, onSignLogIn) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              AvatarGlow(
                endRadius: 90,
                duration: Duration(seconds: 2),
                glowColor: Colors.grey,
                repeat: true,
                repeatPauseDuration: Duration(seconds: 0),
                startDelay: Duration(seconds: 1),
                child: Material(
                  elevation: 0.0,
                  shape: CircleBorder(),
                  color: Colors.transparent,
                  child: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    backgroundImage: AssetImage("assets/ic_launcher.png"),
                    radius: 60.0,
                  )
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              Text(
                'E aí?!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 40.0,
                  color: Theme.of(context).primaryColor
                ),
              ),
              Text(
                'Bem vindo ao Perna!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 35.0,
                  color: Theme.of(context).primaryColor
                ),
              ),
              SizedBox(
                height: 50.0,
              ),
              LogAndSignInButton(
                isSignIn: true,
                text: 'Primeira vez por aqui',
                onPressed: (){
                  setState(() {
                    this.isLoading = true;
                  });
                  onSignLogIn(SignLogin.sign).whenComplete((){
                    setState(() {
                      this.isLoading = false;
                    });
                  });
                }
              ),
              SizedBox(
                height: 20.0,
              ),
              LogAndSignInButton(
                text: 'Já estive aqui',
                onPressed: (){
                  setState(() {
                    this.isLoading = true;
                  });
                  onSignLogIn(SignLogin.login).whenComplete((){
                    setState(() {
                      this.isLoading = false;
                    });
                  });
                }
              )
            ],
          )
        ),
      ),
    );
  }
}
