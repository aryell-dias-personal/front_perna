import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:perna/constants/constants.dart';
import 'package:perna/models/agent.dart';
import 'package:perna/services/directions.dart';
import 'package:perna/widgets/myGoogleMap.dart';
import 'package:perna/models/askedPoint.dart';
import 'package:perna/models/point.dart';
import 'package:perna/pages/askedPointPage.dart';
import 'package:random_color/random_color.dart';

class MapListener extends StatefulWidget {
  final String email;
  final Firestore firestore;
  final Function preExecute;
  final Function(LatLng, String, MarkerType) putMarker;
  final List<LatLng> points;
  final Set<Marker> markers;
  final Function setVisiblePin;

  const MapListener({
    @required this.email, 
    @required this.firestore, 
    @required this.preExecute, 
    @required this.putMarker, 
    @required this.points, 
    @required this.markers, 
    @required this.setVisiblePin
  });

  @override
  _MapListenerState createState() => _MapListenerState(
    email: this.email,
    firestore: this.firestore, 
    preExecute: this.preExecute, 
    putMarker: this.putMarker, 
    points: this.points, 
    markers: this.markers,
    setVisiblePin: this.setVisiblePin
  );
}

class _MapListenerState extends State<MapListener> {
  final String email;
  final Firestore firestore;
  final Function preExecute;
  final Function(LatLng, String, MarkerType) putMarker;
  final List<LatLng> points;
  final Set<Marker> markers;
  final Function setVisiblePin;
  Set<Polyline> polyline = Set();
  Set<Marker> nextPlaces = Set();
  Set<Marker> watchedMarkers = Set();
  DirectionsService directionsService = DirectionsService();
  Map<String, List<LatLng>> pointsPerRoute = {};
  Map<List<LatLng>, List<LatLng>> routeCoordsCache = {};
  List<String> agentIds = [];
  StreamSubscription<QuerySnapshot> agentIdsSubscription;
  StreamSubscription<QuerySnapshot> watchAskedPointSubscription;
  StreamSubscription<QuerySnapshot> watchAgentsSubscription;

  _MapListenerState({
    @required this.email, 
    @required this.firestore, 
    @required this.preExecute, 
    @required this.putMarker, 
    @required this.points, 
    @required this.markers, 
    @required this.setVisiblePin
  });

  @override
  void dispose() {
    super.dispose();
    watchAskedPointSubscription.cancel();
    watchAgentsSubscription.cancel();
    agentIdsSubscription.cancel();
  }

  _buildRouteCoords(List<LatLng> points) async {
    if(points.length >= 2){
      List<LatLng> coords = await directionsService.getRouteBetweenCoordinates(apiKey, points);
      if (coords.isNotEmpty) return coords;
    }
    return null;
  }  

  _addPolyline(List<LatLng> points, {String name}) async {
    if(!routeCoordsCache.containsKey(points)){
      List<LatLng> routeCoords = await this._buildRouteCoords(points);
      if(routeCoords != null) {
        PolylineId polylineId = PolylineId(name ?? "MyRoute");
        setState(() {
          this.routeCoordsCache[points] = routeCoords;
          this.polyline.removeWhere((Polyline polyline)=>polyline.polylineId==polylineId);
          this.polyline.add(
            Polyline(
              geodesic: true,
              zIndex: name==null ? 0 : 1,
              jointType: JointType.round,
              polylineId: polylineId, visible: name == null,
              points: routeCoords.length >1 ? routeCoords: routeCoords, 
              width: 6, color: name==null ? Theme.of(context).primaryColor : RandomColor().randomColor(),
              startCap: Cap.roundCap, endCap: Cap.buttCap
            )
          );
        });
      }
    }
  }

  void _addNextPlace(AskedPoint askedPoint) async {
    BitmapDescriptor bitmapDescriptor = await BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5), 
      'icons/bell_small.png'
    );
    setState(() {
      this.nextPlaces.add(Marker(
        consumeTapEvents: true,
        onTap: (){
          Navigator.push(context, 
            MaterialPageRoute(
              builder: (context) => AskedPointPage(askedPoint: askedPoint, readOnly: true, clear: (){})
            )
          );
        },
        markerId: MarkerId(askedPoint.origin.toString()),
        icon: bitmapDescriptor,
        position: askedPoint.origin
      ));
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      agentIdsSubscription = this.firestore.collection("agent").where('email', isEqualTo: this.email)
        .where('processed', isEqualTo: true)
        .where('old', isEqualTo: false)
        .snapshots().listen((QuerySnapshot agentSnapshot) {
          DateTime now = DateTime.now();
          setState(() {
            this.agentIds = agentSnapshot.documents.fold(<String>[], (List<String> acc, DocumentSnapshot document) {
              Agent agent = Agent.fromJson(document.data);
              if(agent.askedStartAt.isBefore(now)){
                acc.add(document.documentID);
              }
              return acc;
            });
          });
        });
      watchAskedPointSubscription = firestore.collection("askedPoint").where('email', isEqualTo: email)
        .where('processed', isEqualTo: true)
        .where('askedEndAt', isGreaterThanOrEqualTo: DateTime.now().millisecondsSinceEpoch/1000)
        .orderBy('askedEndAt').limit(1).snapshots().listen((QuerySnapshot askedPointSnapshot){
          if(askedPointSnapshot.documents.isNotEmpty){
            AskedPoint askedPoint = AskedPoint.fromJson(askedPointSnapshot.documents.first.data);
            if(askedPoint.origin != null)
              this._addNextPlace(askedPoint);
          }
        });
      watchAgentsSubscription = this.firestore.collection("agent")
        .where('watchedBy', arrayContains: this.email)
        .snapshots().listen((QuerySnapshot agentSnapshot) {
          DateTime now = DateTime.now();
          List<Agent> agents =  agentSnapshot.documents.fold(<Agent>[], (List<Agent> acc, DocumentSnapshot document) {
            Agent agent = Agent.fromJson(document.data);
            if(agent.askedStartAt.isBefore(now)){
              if(agent.position!=null) _addAgentMarker(agent);
              List<LatLng> points = agent.route.fold(<LatLng>[], (List<LatLng> acc, Point curr)=>acc+[curr.local]);
              if(!_pointsPerRouteContains(points, this.email)){
                this.pointsPerRoute[this.email] = points;
                this._addPolyline(points, name: this.email);
              }
              acc.add(agent);
            }
            return acc;
          });
          setState(() {
            if(agents.length==0) this.watchedMarkers.clear();
          });
        });
    });
  }

  Future<Marker> _buildCarMarker(Agent agent) async {
    MarkerId id = MarkerId(email);
    Marker marker = Marker(
      markerId: id,
      position: agent.position,
      consumeTapEvents: true,
      onTap: () async {
        Function(Polyline) findPolyline = (polyline)=>polyline.polylineId.value==email;
        Function(Polyline) findOldestPolyline = (polyline)=>polyline.visible && polyline.polylineId.value != "MyRoute";
        if(this.polyline.isNotEmpty){
          Polyline oldestPolyline = this.polyline.singleWhere(findPolyline, orElse: null);
          Polyline oldPolyline = this.polyline.singleWhere(findPolyline);
          this.setVisiblePin(agent, oldPolyline);
          setState(() {
            if(oldestPolyline != null) {
              this.polyline.removeWhere(findOldestPolyline);
              this.polyline.add(oldestPolyline.copyWith(visibleParam: false));
            }
            this.polyline.removeWhere(findPolyline);
            this.polyline.add(oldPolyline.copyWith(visibleParam: !oldPolyline.visible));
          });
        }
      },
      icon: await BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5), 
        'icons/car_small.png'
      )
    );
    return marker;
  }
  
  void _addAgentMarker(Agent agent) async {
    Marker _marker = await _buildCarMarker(agent);
    setState(() {
      this.markers.removeWhere((marker)=> marker.markerId == _marker.markerId);
      watchedMarkers.add(_marker);
    });
  }

  bool _pointsPerRouteContains(List<LatLng> points, String email){
    if(!this.pointsPerRoute.containsKey(email)) return false;
    List<LatLng> previousPoints = this.pointsPerRoute[this.email];
    return previousPoints.toString() == points.toString();
  }

  @override
  Widget build(BuildContext context) {
    _addPolyline(this.points);
    return MyGoogleMap(
      agentIds: this.agentIds,
      email: this.email,
      firestore: this.firestore,
      markers: this.markers,
      nextPlaces: this.nextPlaces,
      points: this.points,
      polyline: this.polyline,
      preExecute: this.preExecute,
      putMarker: this.putMarker,
      watchedMarkers: this.watchedMarkers
    );
  }
}