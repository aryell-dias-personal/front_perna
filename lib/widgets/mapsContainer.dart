import 'dart:async';
import 'package:android_intent/android_intent.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:perna/constants/constants.dart';
import 'package:perna/helpers/appLocalizations.dart';
import 'package:perna/models/agent.dart';
import 'package:perna/widgets/floatingAnimatedButton.dart';
import 'package:perna/widgets/mapListener.dart';
import 'package:perna/widgets/reactiveFloatingButton.dart';
import 'package:perna/widgets/searchLocation.dart';
import 'package:perna/models/askedPoint.dart';
import 'package:perna/pages/askedPointPage.dart';
import 'package:perna/pages/expedientPage.dart';
import 'package:toast/toast.dart';

class MapsContainer extends StatefulWidget {
  final Function preExecute;
  final String email;
  final Firestore firestore;
  final Function changeSideMenuState;
  final Function setVisiblePin;
  final Function getRefreshToken;
  final AnimationController controller;

  const MapsContainer({
    @required this.setVisiblePin, 
    @required this.preExecute, 
    @required this.changeSideMenuState, 
    @required this.controller, 
    @required this.getRefreshToken, 
    @required this.email, 
    @required this.firestore
  });

  @override
  _MapsContainerState createState() => _MapsContainerState(
    setVisiblePin: this.setVisiblePin,
    preExecute: this.preExecute,
    changeSideMenuState: this.changeSideMenuState,
    controller: this.controller,
    email: this.email,
    firestore: this.firestore,
    getRefreshToken: this.getRefreshToken
  );
}

class _MapsContainerState extends State<MapsContainer> {
  final Function preExecute;
  final String email;
  final Firestore firestore;
  final Function changeSideMenuState;
  final Function getRefreshToken;
  final Function setVisiblePin;
  final AnimationController controller;
  bool isPinVisible = false;
  BitmapDescriptor originPin;
  BitmapDescriptor destinyPin;
  List<LatLng> points = [];
  Set<Marker> markers = Set();
  StreamSubscription<QuerySnapshot> agentsListener;

  _MapsContainerState({
    @required this.setVisiblePin, 
    @required this.email, 
    @required this.firestore, 
    @required this.getRefreshToken, 
    @required this.changeSideMenuState, 
    @required this.controller, 
    @required this.preExecute, 
  });
  
  @override
  void dispose() {
    super.dispose();
    agentsListener.cancel();
  }

  @override
  void initState() {
    super.initState();
    BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 2.5), 'icons/bus_small.png'
    ).then((BitmapDescriptor originPin) => setState((){
      this.originPin = originPin;
    }));
    BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 2.5), 'icons/red-flag_small.png'
    ).then((BitmapDescriptor destinyPin) => setState((){
      this.destinyPin = destinyPin;
    }));
    setState(() {
      this.originPin = originPin;
      this.destinyPin = destinyPin;
      this.agentsListener = this._initAgentListener();
    });
  }

  void addNewExpedient(){
    if(this.markers.length == 1){
      Agent agent = Agent(
        friendlyGarage: markers.first.infoWindow.snippet,
        garage: markers.first.position
      );
      Navigator.push(context, 
        MaterialPageRoute(
          builder: (context) => ExpedientPage(agent: agent, readOnly: false, clear: this.markers.clear, getRefreshToken: this.getRefreshToken)
        )
      );
    } else {
      Toast.show(AppLocalizations.of(context).translate("select_one_point"), 
        context, backgroundColor: Colors.redAccent, duration: 3);
    }
  }

  void addNewAsk() {
    if(this.markers.length == 2){
      AskedPoint askedPoint = AskedPoint(
        friendlyOrigin: markers.first.infoWindow.snippet,
        friendlyDestiny: markers.last.infoWindow.snippet,
        origin: markers.first.position,
        destiny: markers.last.position
      );
      Navigator.push(context, 
        MaterialPageRoute(
          builder: (context) => AskedPointPage(askedPoint: askedPoint, readOnly: false, clear: this.markers.clear, getRefreshToken: this.getRefreshToken)
        )
      );
    } else {
      Toast.show(AppLocalizations.of(context).translate("select_two_points"),
        context, backgroundColor: Colors.redAccent, duration: 3);
    }
  }

  void putMarker(LatLng location, String description, MarkerType type) async {
    preExecute();
    LatLng position = LatLng(location.latitude, location.longitude);
    String title = type == MarkerType.origin ? "Partida ou garagem" : "Chegada";
    MarkerId markerId =  MarkerId(position.toString());
    Marker marker = Marker(
      markerId: markerId,
      icon: type == MarkerType.origin ? this.originPin : this.destinyPin,
      infoWindow: InfoWindow(title: title, snippet: description),
      consumeTapEvents: true,
      onTap: () => _onTapMarker(markerId, position), 
      position: position
    );
    setState(() {
      this.markers.removeWhere((marker) => marker.infoWindow.title == title);
      this.markers.add(marker);
    });
  }

  void navigate() {
    preExecute();
    String origin = "${this.points.first.latitude},${this.points.first.longitude}";
    List<LatLng> latLngWayPoints = this.points.sublist(1,this.points.length-1);
    String waypoints = latLngWayPoints.fold<String>("",(String acc, LatLng curr){
      String currLocation = "${curr.latitude},${curr.longitude}";
      if(curr == latLngWayPoints.first) return "$currLocation";
      return "$acc|$currLocation";
    });
    String destiny = "${this.points.last.latitude},${this.points.last.longitude}";
    final AndroidIntent intent = new AndroidIntent(
      action: 'action_view',
      data: Uri.encodeFull(
        "https://www.google.com/maps/dir/?api=1&origin=$origin&destination=$destiny&waypoints=$waypoints&travelmode=driving&dir_action=navigate"),
      package: 'com.google.android.apps.maps'
    );
    intent.launch();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        MapListener(
          email: this.email,
          firestore: this.firestore,
          markers: this.markers,
          points: this.points,
          putMarker: this.putMarker,
          preExecute: preExecute,
          setVisiblePin: (Agent agent, Polyline oldPolyline) {
            setState(() {
              this.isPinVisible = !oldPolyline.visible;
            });
            this.setVisiblePin(agent, oldPolyline);
          }
        ),
        SearchLocation(
          preExecute: preExecute,
          markers: this.markers,
          onStartPlaceSelected: (location, description) => putMarker(LatLng(location.lat, location.lng), description, MarkerType.origin),
          onEndPlaceSelected: (location, description) => putMarker(LatLng(location.lat, location.lng), description, MarkerType.destiny)
        )
      ]  + (this.points==null || this.points.length <= 1 ? [] : [
        FloatingAnimatedButton(
          heroTag: "1",
          bottom: this.isPinVisible? 190 : 90,
          color: Theme.of(context).primaryColor,
          child: Icon(Icons.navigation, size: 30,
            color: Theme.of(context).backgroundColor),
          description: AppLocalizations.of(context).translate("navegate"),
          onPressed: this.navigate,
        )
      ]) + [
        ReactiveFloatingButton(
          bottom: this.isPinVisible? 115 : 15,
          controller: this.controller,
          defaultFunction: this.changeSideMenuState,
          length: this.markers.length,
          addNewExpedient: this.addNewExpedient,
          addNewAsk: this.addNewAsk
        )
      ]
    );
  }

  StreamSubscription<QuerySnapshot> _initAgentListener(){
    return this.firestore.collection("agent").where('email', isEqualTo: this.email)
      .where('processed', isEqualTo: true)
      .where('askedEndAt', isGreaterThanOrEqualTo: DateTime.now().millisecondsSinceEpoch/1000)
      .orderBy('askedEndAt').limit(1).snapshots().listen((QuerySnapshot agentSnapshot){
        if(agentSnapshot.documents.isNotEmpty){
          Agent agent = Agent.fromJson(agentSnapshot.documents.first.data);
          if(agent.route != null){
            List<LatLng> points = agent.route.map<LatLng>((point)=>point.local).toList();
            setState(() {
              this.points.addAll(points);
            });
          }
        }
    });
  }

  _onTapMarker(MarkerId markerId, LatLng position) {
    setState(() {
      if(this.markers.length == 2 && this.markers.first.markerId.value == position.toString()){
        Marker marker = this.markers.last;
        this.markers.clear();
        this.markers.add(marker.copyWith(
          iconParam: originPin,
          infoWindowParam: marker.infoWindow.copyWith(
            titleParam: "Partida ou garagem"
          ) 
        ));
      } else {
        this.markers.removeWhere((marker) => marker.markerId.value == position.toString());
      }
    });
  }
}