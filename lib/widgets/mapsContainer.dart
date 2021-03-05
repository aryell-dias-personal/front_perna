import 'dart:async';
import 'package:android_intent/android_intent.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:perna/constants/constants.dart';
import 'package:perna/helpers/appLocalizations.dart';
import 'package:perna/helpers/showSnackBar.dart';
import 'package:perna/models/agent.dart';
import 'package:perna/services/driver.dart';
import 'package:perna/services/user.dart';
import 'package:perna/store/state.dart';
import 'package:perna/widgets/floatingAnimatedButton.dart';
import 'package:perna/widgets/mapListener.dart';
import 'package:perna/widgets/reactiveFloatingButton.dart';
import 'package:perna/widgets/searchLocation.dart';
import 'package:perna/models/askedPoint.dart';
import 'package:perna/pages/askedPointPage.dart';
import 'package:perna/pages/expedientPage.dart';

class MapsContainer extends StatefulWidget {
  final Function preExecute;
  final String email;
  final FirebaseFirestore firestore;
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
  _MapsContainerState createState() => _MapsContainerState();
}

class _MapsContainerState extends State<MapsContainer> {
  bool isPinVisible = false;
  BitmapDescriptor originPin;
  BitmapDescriptor destinyPin;
  List<LatLng> points = [];
  Set<Marker> markers = Set();
  StreamSubscription<QuerySnapshot> agentsListener;
  
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

  void addNewExpedient() async {
    if(this.markers.length == 1){
      List<String> snippet1 = markers.first.infoWindow.snippet.split('</>');
      Agent agent = Agent(
        friendlyGarage: snippet1.first,
        region: snippet1.length > 1 ? [
          snippet1.last
        ] : null,
        garage: markers.first.position
      );
      Navigator.push(context, 
        MaterialPageRoute(
          builder: (context) => Scaffold(
            body: StoreConnector<StoreState, DriverService>(
              builder: (context, driverService) => ExpedientPage(
                agent: agent, 
                readOnly: false,
                driverService: driverService, 
                clear: this.markers.clear, 
                getRefreshToken: widget.getRefreshToken
              ),
              converter: (store)=>store.state.driverService
            )
          )
        )
      );
    } else {
      showSnackBar(AppLocalizations.of(context).translate("select_one_point"), 
        Colors.redAccent, context);
    }
  }

  void addNewAsk() async {
    if(this.markers.length == 2){
      List<String> snippet1 = markers.first.infoWindow.snippet.split('</>');
      List<String> snippet2 = markers.last.infoWindow.snippet.split('</>');
      AskedPoint askedPoint = AskedPoint(
        friendlyOrigin: snippet1.first,
        friendlyDestiny: snippet2.first,
        region: snippet1.length > 1 && snippet2.length > 1 ? [
          snippet1.last,
          snippet2.last
        ] : null,
        origin: markers.first.position,
        destiny: markers.last.position
      );
      Navigator.push(context, 
        MaterialPageRoute(
          builder: (context) => Scaffold(
            body: StoreConnector<StoreState, UserService>(
              builder: (context, userService) => AskedPointPage(
                userService: userService, 
                askedPoint: askedPoint, 
                readOnly: false, 
                clear: this.markers.clear, 
                getRefreshToken: widget.getRefreshToken
              ),
              converter: (store)=>store.state.userService
            )
          )
        )
      );
    } else {
      showSnackBar(AppLocalizations.of(context).translate("select_two_points"),
        Colors.redAccent, context);
    }
  }

  void putMarker(LatLng location, String description, MarkerType type, String region) async {
    widget.preExecute();
    LatLng position = LatLng(location.latitude, location.longitude);
    String title = type == MarkerType.origin ? "Partida ou garagem" : "Chegada";
    MarkerId markerId =  MarkerId(position.toString());
    Marker marker = Marker(
      markerId: markerId,
      icon: type == MarkerType.origin ? this.originPin : this.destinyPin,
      infoWindow: InfoWindow(title: title, snippet: "$description</>$region"),
      consumeTapEvents: true,
      onTap: () => _onTapMarker(markerId, position), 
      position: position
    );
    setState(() {
      if(this.markers.length > 1) {
        Set<Marker> newMarkers = this.markers.map<Marker>((currMarker) {
          if(currMarker.infoWindow.title == title) {
            return marker;
          }
          return currMarker;
        }).toSet();
        this.markers.clear();
        this.markers.addAll(newMarkers);
      } else {
        this.markers.add(marker);
      }
    });
  }

  void navigate() {
    widget.preExecute();
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
          email: widget.email,
          firestore: widget.firestore,
          markers: this.markers,
          points: this.points,
          putMarker: this.putMarker,
          preExecute: widget.preExecute,
          setVisiblePin: (Agent agent, Polyline oldPolyline) {
            setState(() {
              this.isPinVisible = !oldPolyline.visible;
            });
            widget.setVisiblePin(agent, oldPolyline);
          }
        ),
        SearchLocation(
          preExecute: widget.preExecute,
          markers: this.markers,
          onStartPlaceSelected: (location, description, region) => putMarker(LatLng(location.lat, location.lng), description, MarkerType.origin, region),
          onEndPlaceSelected: (location, description, region) => putMarker(LatLng(location.lat, location.lng), description, MarkerType.destiny, region)
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
          controller: widget.controller,
          defaultFunction: widget.changeSideMenuState,
          length: this.markers.length,
          addNewExpedient: this.addNewExpedient,
          addNewAsk: this.addNewAsk
        )
      ]
    );
  }

  StreamSubscription<QuerySnapshot> _initAgentListener(){
    return widget.firestore.collection("agent").where('email', isEqualTo: widget.email)
      .where('processed', isEqualTo: true)
      .where('askedEndAt', isGreaterThanOrEqualTo: DateTime.now().millisecondsSinceEpoch/1000)
      .orderBy('askedEndAt').limit(1).snapshots().listen((QuerySnapshot agentSnapshot){
        if(agentSnapshot.docs.isNotEmpty){
          Agent agent = Agent.fromJson(agentSnapshot.docs.first.data());
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