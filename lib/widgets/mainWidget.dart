import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:perna/models/agent.dart';
import 'package:perna/widgets/AnimatedSideMenu.dart';
import 'package:perna/widgets/pinInfo.dart';
import 'package:perna/widgets/mapsContainer.dart';
import 'package:perna/widgets/sideMenu.dart';

class MainWidget extends StatefulWidget {
  final String name;
  final String email;
  final String photoUrl;
  final Firestore firestore;
  final Function logout;
  final Future<IdTokenResult> Function() getRefreshToken;

  const MainWidget({
    Key key, 
    @required this.photoUrl, 
    @required this.getRefreshToken,
    @required this.firestore, 
    @required this.name,
    @required this.email, 
    @required this.logout,
  }) : super(key: key);

  @override
  _MainWidgetState createState() {
    return _MainWidgetState(
      getRefreshToken: this.getRefreshToken,
      firestore: this.firestore,
      photoUrl: this.photoUrl, 
      email: this.email, 
      name: this.name, 
      logout: this.logout
    );
  }
}

class _MainWidgetState extends State<MainWidget> with SingleTickerProviderStateMixin {
  final String name;
  final String email;
  final String photoUrl;
  final Firestore firestore;
  final Function logout;  
  final Future<IdTokenResult> Function() getRefreshToken;
  Agent visiblePin;
  bool isSideMenuOpen = false;
  bool isPinVisible = false;
  AnimationController controller;

  @override
  void initState() {
    super.initState();
    setState(() {
      this.controller = AnimationController(duration: const Duration(milliseconds: 200), vsync:this);
    });
  }

  _MainWidgetState({
    @required this.photoUrl, 
    @required this.firestore, 
    @required this.name,
    @required this.getRefreshToken,
    @required this.email, 
    @required this.logout,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Stack(
        children: <Widget>[
          MapsContainer(
            preExecute: (){ if(this.isSideMenuOpen) changeSideMenuState(); },
            changeSideMenuState: this.changeSideMenuState,
            controller: this.controller,
            email: this.email,
            firestore: this.firestore,
            getRefreshToken: this.getRefreshToken,
            setVisiblePin: (Agent agent, Polyline oldPolyline) { 
              this.setState((){
                this.isPinVisible = !oldPolyline.visible;
                visiblePin = agent;
              });
            }
          ),
          PinInfo(
            visible: this.isPinVisible,
            agent: this.visiblePin
          ),
          AnimatedSideMenu(
            isOpen: this.isSideMenuOpen,
            sideMenu: SideMenu(
              email: this.email, 
              name: this.name, 
              logout: this.logout, 
              photoUrl: this.photoUrl,
              textColor: Theme.of(context).primaryColor
            )
          )
        ],
      )
    );
  }

  changeSideMenuState(){
    setState(() {
      isSideMenuOpen =! isSideMenuOpen;
      isSideMenuOpen ? controller.forward() : controller.reverse();
    });
  }
}