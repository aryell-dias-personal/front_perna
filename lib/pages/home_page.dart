import 'package:perna/main.dart';
import 'package:perna/services/sign_in.dart';
import 'package:perna/store/actions.dart';
import 'package:perna/store/state.dart';
import 'package:perna/widgets/home/home_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    @required this.email,
  });

  final String email;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<StoreState, Map<String, dynamic>>(
        converter: (Store<StoreState> store) {
      return <String, dynamic>{
        'logoutFunction': () {
          getIt<SignInService>().logOut(
              user: store.state.user,
              messagingToken: store.state.messagingToken);
          store.dispatch(Logout());
        },
        'photoUrl': store.state.user?.photoUrl,
        'email': store.state.user?.email,
        'name': store.state.user?.name
      };
    }, builder: (BuildContext context, Map<String, dynamic> resources) {
      return HomeWidget(
          email: resources['email'] as String,
          name: resources['name'] as String,
          logout: resources['logoutFunction'] as Function(),
          photoUrl: resources['photoUrl'] as String);
    });
  }
}
