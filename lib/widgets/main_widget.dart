import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:perna/models/agent.dart';
import 'package:perna/widgets/animated_side_menu.dart';
import 'package:perna/widgets/pin_info.dart';
import 'package:perna/widgets/maps_container.dart';
import 'package:perna/widgets/side_menu.dart';

class MainWidget extends StatefulWidget {
  const MainWidget({
    Key key, 
    @required this.photoUrl, 
    @required this.getRefreshToken,
    @required this.firestore, 
    @required this.name,
    @required this.email, 
    @required this.logout,
  }) : super(key: key);

  final String name;
  final String email;
  final String photoUrl;
  final FirebaseFirestore firestore;
  final Function() logout;
  final Future<String> Function() getRefreshToken;

  @override
  _MainWidgetState createState() {
    return _MainWidgetState();
  }
}

class _MainWidgetState extends State<MainWidget> with SingleTickerProviderStateMixin {
  Agent visiblePin;
  bool isSideMenuOpen = false;
  bool isPinVisible = false;
  AnimationController controller;

  @override
  void initState() {
    super.initState();
    setState(() {
      controller = AnimationController(duration: const Duration(milliseconds: 200), vsync:this);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        MapsContainer(
          preExecute: (){ if(isSideMenuOpen) changeSideMenuState(); },
          changeSideMenuState: changeSideMenuState,
          controller: controller,
          email: widget.email,
          firestore: widget.firestore,
          getRefreshToken: widget.getRefreshToken,
          setVisiblePin: (Agent agent, Polyline oldPolyline) { 
            setState((){
              isPinVisible = !oldPolyline.visible;
              visiblePin = agent;
            });
          }
        ),
        PinInfo(
          visible: isPinVisible,
          agent: visiblePin
        ),
        AnimatedSideMenu(
          isOpen: isSideMenuOpen,
          sideMenu: SideMenu(
            email: widget.email, 
            name: widget.name, 
            logout: widget.logout, 
            photoUrl: widget.photoUrl,
            textColor: Theme.of(context).primaryColor
          )
        )
      ],
    );
  }

  void changeSideMenuState(){
    setState(() {
      isSideMenuOpen =! isSideMenuOpen;
      isSideMenuOpen ? controller.forward() : controller.reverse();
    });
  }
}