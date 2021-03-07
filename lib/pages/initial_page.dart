import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:loading/loading.dart';
import 'package:perna/helpers/app_localizations.dart';
import 'package:perna/helpers/show_snack_bar.dart';
import 'package:perna/main.dart';
import 'package:perna/models/sign_in_response.dart';
import 'package:perna/models/user.dart';
import 'package:perna/services/sign_in.dart';
import 'package:perna/store/actions.dart';
import 'package:perna/store/state.dart';
import 'package:flutter/material.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:perna/widgets/log_and_sign_in_button.dart';
import 'package:intl/intl.dart';
import 'package:redux/redux.dart';

enum SignLogin { sign, login}

class InitialPage extends StatefulWidget {
  const InitialPage({@required this.messagingToken});

  final String messagingToken;

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
        converter: (Store<StoreState> store) => (SignLogin choice) async {
          final Locale locale = AppLocalizations.of(context).locale;
          final String localeName = '${locale.languageCode}_${locale.countryCode.toUpperCase()}';
          final String currencyName = NumberFormat.simpleCurrency(locale: localeName).currencyName.toLowerCase();
          final SignInResponse signInResponse = choice == SignLogin.sign ? 
            await getIt<SignInService>().signIn(widget.messagingToken, currencyName) : 
            await getIt<SignInService>().logIn(widget.messagingToken);
          final User user = signInResponse?.user;
          if(user==null){
            showSnackBar(
              AppLocalizations.of(context).translate('unrecognized_user'), 
              Colors.redAccent, context
            );
          } else {
            store.dispatch(choice == SignLogin.sign? SignIn(user):LogIn(user));
          }
        },
        builder: (BuildContext context, dynamic Function(SignLogin) onSignLogIn) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const AvatarGlow(
              endRadius: 90,
              glowColor: Colors.grey,
              repeatPauseDuration: Duration(),
              startDelay: Duration(seconds: 1),
              child: Material(
                shape: CircleBorder(),
                color: Colors.transparent,
                child: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  backgroundImage: AssetImage('assets/ic_launcher.png'),
                  radius: 60.0,
                )
              ),
            ),
            const SizedBox(
              height: 20.0,
            ),
            Text(
              AppLocalizations.of(context).translate('hey_there'),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 40.0,
                color: Theme.of(context).primaryColor
              ),
            ),
            Text(
              AppLocalizations.of(context).translate('welcome'),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 35.0,
                color: Theme.of(context).primaryColor
              ),
            ),
            const SizedBox(
              height: 50.0,
            ),
            LogAndSignInButton(
              isSignIn: true,
              text: AppLocalizations.of(context).translate('first_time'),
              onPressed: (){
                setState(() {
                  isLoading = true;
                });
                onSignLogIn(SignLogin.sign).whenComplete((){
                  setState(() {
                    isLoading = false;
                  });
                });
              }
            ),
            const SizedBox(
              height: 20.0,
            ),
            LogAndSignInButton(
              text: AppLocalizations.of(context).translate('have_been_here'),
              onPressed: (){
                setState(() {
                  isLoading = true;
                });
                onSignLogIn(SignLogin.login).whenComplete((){
                  setState(() {
                    isLoading = false;
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
