import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:perna/models/agent.dart';
import 'package:perna/widgets/AnimatedSideMenu.dart';
import 'package:perna/widgets/floatingAnimatedButton.dart';
import 'package:perna/widgets/myGoogleMap.dart';
import 'package:perna/widgets/reactiveFloatingButton.dart';
import 'package:perna/widgets/sideMenu.dart';
import 'package:perna/widgets/searchLocation.dart';
import 'package:android_intent/android_intent.dart';
import 'package:toast/toast.dart';

class MainWidget extends StatefulWidget {
  final String name;
  final String email;
  final String photoUrl;
  final Set<Marker> markers;
  final Set<Marker> nextPlaces;
  final Set<Polyline> polyline;
  final List<LatLng> points;
  final Firestore firestore;
  final Function logout;
  final Function onTap;
  final Function putMarker;
  final Function onMapCreated;
  final Function cancelselection;
  final Function addNewAsk;
  final Function addNewExpedient;
  final Function centralize;

  const MainWidget({
    Key key, 
    @required this.photoUrl, 
    @required this.firestore, 
    @required this.name,
    @required this.email, 
    @required this.logout,
    @required this.onTap,
    @required this.putMarker,
    @required this.onMapCreated,
    @required this.polyline, 
    @required this.markers,
    @required this.nextPlaces,
    @required this.cancelselection,
    @required this.addNewExpedient, 
    @required this.centralize, 
    @required this.addNewAsk,
    @required this.points
  }) : super(key: key);

  @override
  _MainWidgetState createState() {
    return _MainWidgetState(
      firestore: this.firestore,
      photoUrl: this.photoUrl, 
      email: this.email, 
      name: this.name, 
      logout: this.logout,
      onTap: this.onTap,
      putMarker: this.putMarker,
      onMapCreated: this.onMapCreated,
      polyline: this.polyline,
      points: this.points,
      markers: this.markers,
      centralize: this.centralize,
      cancelselection: this.cancelselection,
      addNewExpedient: this.addNewExpedient, 
      addNewAsk: this.addNewAsk,
      nextPlaces: this.nextPlaces
    );
  }
}

class _MainWidgetState extends State<MainWidget> with SingleTickerProviderStateMixin {
  final String name;
  final String email;
  final String photoUrl;
  final Set<Polyline> polyline;
  final Set<Marker> markers;
  final Set<Marker> nextPlaces;
  final List<LatLng> points;
  final Firestore firestore;
  final Function logout;
  final Function onTap;
  final Function putMarker;
  final Function onMapCreated;
  final Function cancelselection;
  final Function addNewAsk;
  final Function addNewExpedient;
  final Function centralize;

  Set<Marker> watchedMarkers = Set();
  List<String> agentIds = [];
  LatLng previousLatLng;
  bool isOpen = false;
  StreamSubscription<QuerySnapshot> watchAgentsSubscription;
  StreamSubscription<QuerySnapshot> agentIdsSubscription;
  StreamSubscription<LocationData> sendAgentSubscription;
  AnimationController controller;

  _MainWidgetState({
    @required this.photoUrl, 
    @required this.firestore, 
    @required this.name,
    @required this.email, 
    @required this.logout,
    @required this.onTap,
    @required this.putMarker,
    @required this.nextPlaces,
    @required this.onMapCreated,
    @required this.polyline, 
    @required this.markers,
    @required this.cancelselection,
    @required this.addNewExpedient, 
    @required this.centralize, 
    @required this.addNewAsk,
    @required this.points
  });

  @override
  void dispose() {
    super.dispose();
    watchAgentsSubscription.cancel();
    sendAgentSubscription.cancel();
    agentIdsSubscription.cancel();
  }

  @override
  void initState() {
    super.initState();
    Location location = Location();
    setState(() {
      this.controller = AnimationController(duration: const Duration(milliseconds: 200), vsync:this);
      agentIdsSubscription = firestore.collection("agent").where('email', isEqualTo: this.email)
        .where('processed', isEqualTo: true)
        .where('old', isEqualTo: false)
        .where('askedStartAt', isLessThan: DateTime.now().millisecondsSinceEpoch/1000)
        .snapshots().listen((QuerySnapshot agentSnapshot) {
          setState(() {
            this.agentIds = agentSnapshot.documents.map<String>((DocumentSnapshot document) {
              return document.documentID;
            }).toList();
          });
        });
      sendAgentSubscription = location.onLocationChanged().listen(_updateLocation);
      watchAgentsSubscription = firestore.collection("agent").where('fromEmail', isEqualTo: email)
        .where('processed', isEqualTo: true)
        .where('old', isEqualTo: false)
        .where('askedStartAt', isLessThan: DateTime.now().millisecondsSinceEpoch/1000)
        .snapshots().listen((QuerySnapshot agentSnapshot) {
          _updateMarkers(agentSnapshot.documents);
        });
    });
  }

  void _addCarMarker(Agent agent) async {
    MarkerId id = MarkerId(agent.email);
    Marker _marker = Marker(
      markerId: id,
      position: agent.position,
      consumeTapEvents: true,
      onTap: (){
        Toast.show(
          "Eita, você esbarrou em algo que ainda não foi implementado 😳", 
          context, backgroundColor: Colors.pinkAccent, duration: 3);
        //TODO: mostrar detalhes sobre a viagem como qual o horario de inicio e fim, qual a rota qual o email do motorista, etc.
      },
      icon: await BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5), 
        'icons/car_small.png'
      ),
      infoWindow: InfoWindow(title: "Motorista", snippet: agent.email),
    );
    setState(() {
      this.markers.removeWhere((marker)=> marker.markerId == id);
      watchedMarkers.add(_marker);
    });
  }

  double _calculateDistance(LatLng latLng1, LatLng latLng2){
    int R = 6371000; // metros
    double x = (latLng2.longitude - latLng1.longitude) * cos((latLng1.latitude + latLng2.latitude) / 2);
    double y = (latLng2.latitude - latLng1.latitude);
    double distance = sqrt(x * x + y * y) * R;
    return distance;
  }

  void _updateLocation(LocationData locationData) {
    LatLng currLatLng = LatLng(locationData.latitude, locationData.longitude);
    if(previousLatLng == null || _calculateDistance(previousLatLng, currLatLng)>200){
      setState(() {
        this.previousLatLng = currLatLng;
      });
      this.agentIds.forEach((documentID) async {
        DocumentReference ref = firestore.collection("agent").document(documentID);
        DocumentSnapshot documentSnapshot = await ref.get();
        Agent agent = Agent.fromJson(documentSnapshot.data);
        await ref.updateData({
          'position': "${locationData.latitude},${locationData.longitude}",
          'old': DateTime.now().isAfter(agent.askedEndAt)
        });
      });
    }
  }

  void _updateMarkers(List<DocumentSnapshot> documentList) {
    if(documentList.length==0) this.watchedMarkers.clear();
    documentList.forEach((DocumentSnapshot document) {
      Agent agent = Agent.fromJson(document.data);
      if(agent.position!=null) _addCarMarker(agent);
    });
  }

  _openSideMenu(){
    setState(() {
      isOpen =! isOpen;
      isOpen ? controller.forward() : controller.reverse();
    });
  }

  _navigate(){
    if(this.isOpen) _openSideMenu();
    String origin = "${this.points.first.latitude},${this.points.first.longitude}";
    List<LatLng> latLngWayPoints = this.points.sublist(1,this.points.length-1);
    String waypoints = latLngWayPoints.fold<String>("",(String acc, LatLng curr){
      String currLocation = "${curr.latitude},${curr.longitude}";
      if(curr == latLngWayPoints.first){
        return "$currLocation";
      }
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

  Future _addMarkerWithSearch(location, String description, int type) async {
    if(this.isOpen) _openSideMenu();
    LatLng position = LatLng(location.lat, location.lng);
    BitmapDescriptor bitmapDescriptor = await BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5), 
      type == 0 ? 'icons/bus_small.png' : 'icons/red-flag_small.png'
    );
    setState(() {
      this.markers.removeWhere((marker){
          return  marker.infoWindow.title == (type == 0 ? "Partida ou garagem" : "Chegada") ;
      });
      this.markers.add(
        Marker(markerId: MarkerId(position.toString()),
          icon: bitmapDescriptor,
          infoWindow: InfoWindow(title: type == 0 ? "Partida ou garagem": "Chegada", snippet: description),
          consumeTapEvents: true,
          onTap: (){
            setState(() {
              this.markers.removeWhere((marker){
                return marker.markerId.value == position.toString();
              });
              if(this.markers.length == 1){
                LatLng postion = this.markers.first.position;
                this.markers.clear();
                putMarker(postion);
              }
            });
          }, 
          position: position
        )
      );
      this.centralize(position);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Stack(
        children: <Widget>[
          Stack(
            children: <Widget>[
              MyGoogleMap(
                onTap: this.onTap,
                polyline:this.polyline,
                onLongPress: this.putMarker,
                onMapCreated: this.onMapCreated,
                markers: this.markers.union(this.nextPlaces).union(this.watchedMarkers),
                preExecute: (){ if(this.isOpen) _openSideMenu(); },
              ),
              SearchLocation(
                preExecute: (){ if(this.isOpen) _openSideMenu(); },
                markers: this.markers,
                onStartPlaceSelected: (location, description) async {
                  await _addMarkerWithSearch(location, description, 0);
                },
                onEndPlaceSelected: (location, description) async {
                  await _addMarkerWithSearch(location, description, 1);
                }
              )
            ]  + (this.points==null || this.points.length <= 1 ? [] : [
              FloatingAnimatedButton(
                heroTag: "1",
                bottom: 90,
                color: Theme.of(context).primaryColor,
                child: Icon(
                  Icons.navigation, size: 30,
                  color: Theme.of(context).backgroundColor,
                ),
                description: "Navegar",
                onPressed: this._navigate,
              )
            ]) + [
              ReactiveFloatingButton(
                controller:this.controller,
                defaultFunction:this._openSideMenu,
                length:this.markers.length,
                addNewExpedient:this.addNewExpedient,
                addNewAsk:this.addNewAsk
              )
            ]
          ),
          AnimatedSideMenu(
            isOpen: this.isOpen,
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
}
