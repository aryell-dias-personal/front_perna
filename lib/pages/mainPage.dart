import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:perna/store/actions.dart';
import 'package:perna/store/state.dart';
import 'package:perna/widgets/mainWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'dart:async';

class MainPage extends StatelessWidget {
  final String email;
  final Function onLogout;
  final Future<String> Function() getRefreshToken;
  final FirebaseFirestore firestore;

  MainPage({@required this.email, @required this.onLogout,  @required this.getRefreshToken, @required this.firestore});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<StoreState, Map<String, dynamic>>(
      converter: (store) {
        return {
          'logoutFunction': () {
            this.onLogout(user: store.state.user, messagingToken: store.state.messagingToken);
            store.dispatch(Logout());
          },
          'photoUrl':store.state.user?.photoUrl,
          'email':store.state.user?.email,
          'name':store.state.user?.name
        };
      },
      builder: (context, resources) {
        return MainWidget(
          getRefreshToken: this.getRefreshToken,
          firestore: this.firestore,
          email: resources['email'],
          name: resources['name'],
          logout: resources['logoutFunction'],
          photoUrl: resources['photoUrl']
        );
      }
    );
  }
}
