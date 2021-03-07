import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:perna/constants/constants.dart';
import 'package:perna/models/agent.dart';
import 'package:perna/services/directions.dart';
import 'package:perna/services/user.dart';
import 'package:perna/store/state.dart';
import 'package:perna/widgets/my_google_map.dart';
import 'package:perna/models/askedPoint.dart';
import 'package:perna/models/point.dart';
import 'package:perna/pages/asked_point_page.dart';
import 'package:random_color/random_color.dart';
import 'package:flutter_flavor/flutter_flavor.dart';

class MapListener extends StatefulWidget {
  final String email;
  final FirebaseFirestore firestore;
  final Function preExecute;
  final Function(LatLng, String, MarkerType, String) putMarker;
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
  _MapListenerState createState() => _MapListenerState();
}

class _MapListenerState extends State<MapListener> {
  Function hidePin =() {};
  List<String> agentIds = [];
  Set<Polyline> polyline = Set();
  Set<Marker> nextPlaces = Set();
  Set<Marker> watchedMarkers = Set();
  Map<String, List<LatLng>> pointsPerRoute = {};
  Map<List<LatLng>, List<LatLng>> routeCoordsCache = {};
  StreamSubscription<QuerySnapshot> agentIdsSubscription;
  StreamSubscription<QuerySnapshot> watchAskedPointSubscription;
  StreamSubscription<QuerySnapshot> watchAgentsSubscription;

  DirectionsService directionsService = DirectionsService();

  @override
  void dispose() {
    super.dispose();
    watchAskedPointSubscription.cancel();
    watchAgentsSubscription.cancel();
    agentIdsSubscription.cancel();
  }

  _buildRouteCoords(List<LatLng> points) async {
    if(points.length >= 2){
      List<LatLng> coords = await this.directionsService.getRouteBetweenCoordinates(FlavorConfig.instance.variables['apiKey'], points);
      if (coords.isNotEmpty) return coords;
    }
    return null;
  }  

  _addPolyline(List<LatLng> points, {String name}) async {
    if(!this.routeCoordsCache.containsKey(points)){
      List<LatLng> routeCoords = await this._buildRouteCoords(points);
      if(routeCoords != null) {
        PolylineId polylineId = PolylineId(name ?? 'MyRoute');
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
              builder: (BuildContext context) => Scaffold(
                body: StoreConnector<StoreState, UserService>(
                  builder: (BuildContext context, userService) => AskedPointPage(userService: userService, askedPoint: askedPoint, readOnly: true, clear: (){}),
                  converter: (store)=>store.state.userService
                )
              )
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
      this.agentIdsSubscription = widget.firestore.collection('agent').where('email', isEqualTo: widget.email)
        .where('processed', isEqualTo: true)
        .where('old', isEqualTo: false)
        .snapshots().listen((QuerySnapshot agentSnapshot) {
          DateTime now = DateTime.now();
          setState(() {
            this.agentIds.clear();
            this.agentIds.addAll(agentSnapshot.docs.fold<List<String>>(<String>[], (List<String> acc, DocumentSnapshot document) {
              Agent agent = Agent.fromJson(document.data());
              DateTime askedStartAtTime = agent.date.add(agent.askedStartAt);
              if(askedStartAtTime.isBefore(now)){
                acc.add(document.id);
              }
              return acc;
            }));
          });
        });
      this.watchAskedPointSubscription = widget.firestore.collection('askedPoint').where('email', isEqualTo: widget.email)
        .where('processed', isEqualTo: true)
        .where('askedEndAt', isGreaterThanOrEqualTo: DateTime.now().millisecondsSinceEpoch/1000)
        .orderBy('askedEndAt').limit(1).snapshots().listen((QuerySnapshot askedPointSnapshot){
          if(askedPointSnapshot.docs.isNotEmpty){
            AskedPoint askedPoint = AskedPoint.fromJson(askedPointSnapshot.docs.first.data());
            if(askedPoint.origin != null)
              this._addNextPlace(askedPoint);
          }
        });
      this.watchAgentsSubscription = widget.firestore.collection('agent')
        .where('processed', isEqualTo: true)
        .where('watchedBy', arrayContains: widget.email)
        .where('old', isEqualTo: false)
        .snapshots().listen((QuerySnapshot agentSnapshot) {
          DateTime now = DateTime.now();
          List<Agent> agents =  agentSnapshot.docs.fold(<Agent>[], (List<Agent> acc, DocumentSnapshot document) {
            Agent agent = Agent.fromJson(document.data());
            DateTime askedStartAtTime = agent.date.add(agent.askedStartAt);
            if(askedStartAtTime.isBefore(now)){
              if(agent.position!=null) _addAgentMarker(agent);
              List<LatLng> points = agent.route.fold(<LatLng>[], (List<LatLng> acc, Point curr)=>acc+[curr.local]);
              if(!_pointsPerRouteContains(points, widget.email)){
                this.pointsPerRoute[widget.email] = points;
                this._addPolyline(points, name: widget.email);
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
  
  bool findPolyline(Polyline polyline) {
    return polyline.polylineId.value==widget.email;
  }
  
  bool findOldestPolyline(Polyline polyline) {
    return polyline.visible && polyline.polylineId.value != 'MyRoute';
  }
  
  Future<Marker> _buildCarMarker(Agent agent) async {
    final MarkerId id = MarkerId(widget.email);
    final Marker marker = Marker(
      markerId: id,
      position: agent.position,
      consumeTapEvents: true,
      onTap: () async {
        if(polyline.isNotEmpty){
          final Polyline oldestPolyline = polyline.singleWhere(findPolyline, 
            orElse: () { return null; }
          );
          final Polyline oldPolyline = polyline.singleWhere(findPolyline);
          widget.setVisiblePin(agent, oldPolyline);
          setState(() {
            if(oldestPolyline != null) {
              polyline.removeWhere(findOldestPolyline);
              polyline.add(oldestPolyline.copyWith(visibleParam: false));
            }
            polyline.removeWhere(findPolyline);
            final Polyline newPolyline = oldPolyline.copyWith(
              visibleParam: !oldPolyline.visible
            );
            polyline.add(newPolyline);
            hidePin = () {
              if(newPolyline.visible) {
                polyline.removeWhere(findPolyline);
                widget.setVisiblePin(agent, newPolyline);
                polyline.add(newPolyline.copyWith(
                  visibleParam: !newPolyline.visible
                ));
              }
            };
          });
        }
      },
      icon: await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(devicePixelRatio: 2.5), 
        'icons/car_small.png'
      )
    );
    return marker;
  }
  
  Future<dynamic> _addAgentMarker(Agent agent) async {
    final Marker _marker = await _buildCarMarker(agent);
    setState(() {
      widget.markers.removeWhere(
        (Marker marker)=> marker.markerId == _marker.markerId
      );
      watchedMarkers.add(_marker);
    });
  }

  bool _pointsPerRouteContains(List<LatLng> points, String email){
    if(!pointsPerRoute.containsKey(email)) return false;
    final List<LatLng> previousPoints = pointsPerRoute[widget.email];
    return previousPoints.toString() == points.toString();
  }

  @override
  Widget build(BuildContext context) {
    _addPolyline(widget.points);
    return MyGoogleMap(
      agentIds: agentIds,
      email: widget.email,
      firestore: widget.firestore,
      markers: widget.markers,
      nextPlaces: nextPlaces,
      points: widget.points,
      polyline: polyline,
      preExecute: () {
        hidePin();
        widget.preExecute();
      },
      putMarker: widget.putMarker,
      watchedMarkers: watchedMarkers
    );
  }
}