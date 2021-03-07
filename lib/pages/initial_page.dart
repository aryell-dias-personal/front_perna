import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:loading/loading.dart';
import 'package:perna/helpers/app_localizations.dart';
import 'package:perna/helpers/show_snack_bar.dart';
import 'package:perna/models/signInResponse.dart';
import 'package:perna/models/user.dart';
import 'package:perna/services/signIn.dart';
import 'package:perna/store/actions.dart';
import 'package:perna/store/state.dart';
import 'package:flutter/material.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:perna/widgets/log_and_sign_in_button.dart';
import 'package:intl/intl.dart';

enum SignLogin { sign, login}

class InitialPage extends StatefulWidget {
  final SignInService signInService;
  final String messagingToken;
  InitialPage({@required this.signInService, @required this.messagingToken});

  @override
  _InitialPageState createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: isLoading ? Loading(indicator: BallPulseIndicator(), color: Theme.of(context).primaryColor, size: 100.0) : 
      StoreConnector<StoreState, Function(SignLogin)>(
        converter: (store) => (SignLogin choice) async {
          Locale locale = AppLocalizations.of(context).locale;
          String localeName = '${locale.languageCode}_${locale.countryCode.toUpperCase()}';
          String currencyName = NumberFormat.simpleCurrency(locale: localeName).currencyName.toLowerCase();
          SignInResponse signInResponse = choice == SignLogin.sign ? 
            await widget.signInService.signIn(widget.messagingToken, currencyName) : 
            await widget.signInService.logIn(widget.messagingToken);
          User user = signInResponse?.user;
          if(user==null){
            showSnackBar(
              AppLocalizations.of(context).translate('unrecognized_user'), 
              Colors.redAccent, context
            );
          } else {
            store.dispatch(choice == SignLogin.sign? SignIn(user):LogIn(user));
          }
        },
        builder: (BuildContext context, onSignLogIn) => Column(
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
                  backgroundImage: AssetImage('assets/ic_launcher.png'),
                  radius: 60.0,
                )
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            Text(
              AppLocalizations.of(context).translate('hey_there'),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 40.0,
                color: Theme.of(context).primaryColor
              ),
            ),
            Text(
              AppLocalizations.of(context).translate('welcome'),
              style: const TextStyle(
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
              text: AppLocalizations.of(context).translate('first_time'),
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
              text: AppLocalizations.of(context).translate('have_been_here'),
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
    );
  }
}
