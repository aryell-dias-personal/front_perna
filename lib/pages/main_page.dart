import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:perna/store/actions.dart';
import 'package:perna/store/state.dart';
import 'package:perna/widgets/main_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

class MainPage extends StatelessWidget {
  const MainPage({
    @required this.email, 
    @required this.onLogout,  
    @required this.getRefreshToken, 
    @required this.firestore
  });

  final String email;
  final Function onLogout;
  final Future<String> Function() getRefreshToken;
  final FirebaseFirestore firestore;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<StoreState, Map<String, dynamic>>(
      converter: (Store<StoreState> store) {
        return <String, dynamic>{
          'logoutFunction': () {
            onLogout(
              user: store.state.user, 
              messagingToken: store.state.messagingToken
            );
            store.dispatch(Logout());
          },
          'photoUrl':store.state.user?.photoUrl,
          'email':store.state.user?.email,
          'name':store.state.user?.name
        };
      },
      builder: (BuildContext context, Map<String, dynamic> resources) {
        return MainWidget(
          getRefreshToken: getRefreshToken,
          firestore: firestore,
          email: resources['email'],
          name: resources['name'],
          logout: resources['logoutFunction'],
          photoUrl: resources['photoUrl']
        );
      }
    );
  }
}
