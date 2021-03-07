import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:perna/constants/constants.dart';
import 'package:perna/main.dart';
import 'package:perna/models/agent.dart';
import 'package:perna/services/directions.dart';
import 'package:perna/widgets/my_google_map.dart';
import 'package:perna/models/asked_point.dart';
import 'package:perna/models/point.dart';
import 'package:perna/pages/asked_point_page.dart';
import 'package:random_color/random_color.dart';
import 'package:flutter_flavor/flutter_flavor.dart';

class MapListener extends StatefulWidget {
  const MapListener({
    @required this.email, 
    @required this.preExecute, 
    @required this.putMarker, 
    @required this.points, 
    @required this.markers, 
    @required this.setVisiblePin
  });
  
  final String email;
  final Function preExecute;
  final Function(LatLng, String, MarkerType, String) putMarker;
  final List<LatLng> points;
  final Set<Marker> markers;
  final Function setVisiblePin;

  @override
  _MapListenerState createState() => _MapListenerState();
}

class _MapListenerState extends State<MapListener> {
  Function hidePin;
  List<String> agentIds = <String>[];
  Set<Polyline> polyline = <Polyline>{};
  Set<Marker> nextPlaces = <Marker>{};
  Set<Marker> watchedMarkers = <Marker>{};
  Map<String, List<LatLng>> pointsPerRoute = <String, List<LatLng>> {};
  Map<List<LatLng>, List<LatLng>> routeCoordsCache = <List<LatLng>, List<LatLng>>{};
  StreamSubscription<QuerySnapshot> agentIdsSubscription;
  StreamSubscription<QuerySnapshot> watchAskedPointSubscription;
  StreamSubscription<QuerySnapshot> watchAgentsSubscription;

  @override
  void dispose() {
    super.dispose();
    watchAskedPointSubscription.cancel();
    watchAgentsSubscription.cancel();
    agentIdsSubscription.cancel();
  }

  Future<List<LatLng>> _buildRouteCoords(List<LatLng> points) async {
    if(points.length >= 2){
      final DirectionsService directionsService = getIt<DirectionsService>();
      final List<LatLng> coords = await directionsService.getRouteBetweenCoordinates(FlavorConfig.instance.variables['apiKey'] as String, points);
      if (coords.isNotEmpty) return coords;
    }
    return null;
  }  

  Future<void> _addPolyline(List<LatLng> points, {String name}) async {
    if(!routeCoordsCache.containsKey(points)){
      final List<LatLng> routeCoords = await _buildRouteCoords(points);
      if(routeCoords != null) {
        final PolylineId polylineId = PolylineId(name ?? 'MyRoute');
        setState(() {
          routeCoordsCache[points] = routeCoords;
          polyline.removeWhere((Polyline polyline)=>polyline.polylineId==polylineId);
          polyline.add(
            Polyline(
              geodesic: true,
              zIndex: name==null ? 0 : 1,
              jointType: JointType.round,
              polylineId: polylineId, visible: name == null,
              points: routeCoords.length >1 ? routeCoords: routeCoords, 
              width: 6, color: name==null ? Theme.of(context).primaryColor : RandomColor().randomColor(),
              startCap: Cap.roundCap
            )
          );
        });
      }
    }
  }

  Future<void> _addNextPlace(AskedPoint askedPoint) async {
    final BitmapDescriptor bitmapDescriptor = await BitmapDescriptor.fromAssetImage(const ImageConfiguration(devicePixelRatio: 2.5), 
      'icons/bell_small.png'
    );
    setState(() {
      nextPlaces.add(Marker(
        consumeTapEvents: true,
        onTap: (){
          Navigator.push(context, 
            MaterialPageRoute<AskedPointPage>(
              builder: (BuildContext context) => AskedPointPage(askedPoint: askedPoint, readOnly: true, clear: (){})
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
      agentIdsSubscription = getIt<FirebaseFirestore>().collection('agent')
        .where('email', isEqualTo: widget.email)
        .where('processed', isEqualTo: true)
        .where('old', isEqualTo: false)
        .snapshots().listen((QuerySnapshot agentSnapshot) {
          final DateTime now = DateTime.now();
          setState(() {
            agentIds.clear();
            agentIds.addAll(agentSnapshot.docs.fold<List<String>>(<String>[], (List<String> acc, DocumentSnapshot document) {
              final Agent agent = Agent.fromJson(document.data());
              final DateTime askedStartAtTime = agent.date.add(agent.askedStartAt);
              if(askedStartAtTime.isBefore(now)){
                acc.add(document.id);
              }
              return acc;
            }));
          });
        });
      watchAskedPointSubscription = getIt<FirebaseFirestore>().collection('askedPoint')
        .where('email', isEqualTo: widget.email)
        .where('processed', isEqualTo: true)
        .where('actualEndAt', isGreaterThanOrEqualTo: DateTime.now().microsecondsSinceEpoch/1000)
        .orderBy('actualEndAt').limit(1).snapshots().listen((QuerySnapshot askedPointSnapshot){
          if(askedPointSnapshot.docs.isNotEmpty){
            final AskedPoint askedPoint = AskedPoint.fromJson(askedPointSnapshot.docs.first.data());
            if(askedPoint.origin != null) {
              _addNextPlace(askedPoint);
            }
          }
        });
      watchAgentsSubscription = getIt<FirebaseFirestore>().collection('agent')
        .where('processed', isEqualTo: true)
        .where('watchedBy', arrayContains: widget.email)
        .where('old', isEqualTo: false)
        .snapshots().listen((QuerySnapshot agentSnapshot) {
          final DateTime now = DateTime.now();
          final List<Agent> agents =  agentSnapshot.docs.fold(<Agent>[], (List<Agent> acc, DocumentSnapshot document) {
            final Agent agent = Agent.fromJson(document.data());
            final DateTime askedStartAtTime = agent.date.add(agent.askedStartAt);
            if(askedStartAtTime.isBefore(now)){
              if(agent.position!=null) _addAgentMarker(agent);
              final List<LatLng> points = agent.route.fold(<LatLng>[], (List<LatLng> acc, Point curr)=>acc+<LatLng>[curr.local]).toList();
              if(!_pointsPerRouteContains(points, widget.email)){
                pointsPerRoute[widget.email] = points;
                _addPolyline(points, name: widget.email);
              }
              acc.add(agent);
            }
            return acc;
          });
          setState(() {
            if(agents.isEmpty) watchedMarkers.clear();
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
  
  Future<void> _addAgentMarker(Agent agent) async {
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
      markers: widget.markers,
      nextPlaces: nextPlaces,
      points: widget.points,
      polyline: polyline,
      preExecute: () {
        if(hidePin != null) {
          hidePin();
        }
        widget.preExecute();
      },
      putMarker: widget.putMarker,
      watchedMarkers: watchedMarkers
    );
  }
}