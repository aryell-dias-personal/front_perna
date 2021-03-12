import 'dart:async';
import 'package:android_intent/android_intent.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:perna/constants/constants.dart';
import 'package:perna/helpers/app_localizations.dart';
import 'package:perna/helpers/show_snack_bar.dart';
import 'package:perna/main.dart';
import 'package:perna/models/agent.dart';
import 'package:perna/models/point.dart';
import 'package:perna/widgets/button/floating_animated_button.dart';
import 'package:perna/widgets/map/map_listener.dart';
import 'package:perna/widgets/button/reactive_floating_button.dart';
import 'package:perna/widgets/input/search_location.dart';
import 'package:perna/models/asked_point.dart';
import 'package:perna/pages/asked_point_page.dart';
import 'package:perna/pages/expedient_page.dart';

class MapsContainer extends StatefulWidget {
  const MapsContainer({
    required this.setVisiblePin,
    required this.preExecute,
    required this.changeSideMenuState,
    required this.controller,
    required this.email,
  });

  final Function() preExecute;
  final String email;
  final Function() changeSideMenuState;
  final Function setVisiblePin;
  final AnimationController controller;

  @override
  _MapsContainerState createState() => _MapsContainerState();
}

class _MapsContainerState extends State<MapsContainer> {
  Set<Marker> markers = <Marker>{};
  bool isPinVisible = false;
  late BitmapDescriptor originPin;
  late BitmapDescriptor destinyPin;
  List<LatLng> points = <LatLng>[];
  late StreamSubscription<QuerySnapshot> agentsListener;

  @override
  void dispose() {
    super.dispose();
    agentsListener.cancel();
  }

  @override
  void initState() {
    super.initState();
    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(devicePixelRatio: 2.5),
            'icons/bus_small.png')
        .then((BitmapDescriptor originPin) => setState(() {
              this.originPin = originPin;
            }));
    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(devicePixelRatio: 2.5),
            'icons/red-flag_small.png')
        .then((BitmapDescriptor destinyPin) => setState(() {
              this.destinyPin = destinyPin;
            }));
    setState(() {
      originPin = originPin;
      destinyPin = destinyPin;
      agentsListener = _initAgentListener();
    });
  }

  Future<void> addNewExpedient() async {
    if (markers.length == 1) {
      final List<String> snippet1 =
          markers.first.infoWindow.snippet!.split('</>');
      final Agent agent = Agent(
          friendlyGarage: snippet1.first,
          region: snippet1.length > 1 ? <String>[snippet1.last] : null,
          garage: markers.first.position);
      Navigator.push(
          context,
          MaterialPageRoute<dynamic>(
              builder: (BuildContext context) => ExpedientPage(
                    agent: agent,
                    readOnly: false,
                    clear: markers.clear,
                  )));
    } else {
      showSnackBar(AppLocalizations.of(context).translate('select_one_point'),
          Colors.redAccent, context);
    }
  }

  Future<void> addNewAsk() async {
    if (markers.length == 2) {
      final List<String> snippet1 =
          markers.first.infoWindow.snippet!.split('</>');
      final List<String> snippet2 =
          markers.last.infoWindow.snippet!.split('</>');
      final AskedPoint askedPoint = AskedPoint(
          friendlyOrigin: snippet1.first,
          friendlyDestiny: snippet2.first,
          region: snippet1.length > 1 && snippet2.length > 1
              ? <String>[snippet1.last, snippet2.last]
              : null,
          origin: markers.first.position,
          destiny: markers.last.position);
      Navigator.push(
          context,
          MaterialPageRoute<AskedPointPage>(
            builder: (BuildContext context) => AskedPointPage(
              askedPoint: askedPoint,
              readOnly: false,
              clear: markers.clear,
            ),
          ));
    } else {
      showSnackBar(AppLocalizations.of(context).translate('select_two_points'),
          Colors.redAccent, context);
    }
  }

  Future<void> putMarker(LatLng location, String description, MarkerType type,
      String region) async {
    widget.preExecute();
    final LatLng position = LatLng(location.latitude, location.longitude);
    final String title =
        type == MarkerType.origin ? 'Partida ou garagem' : 'Chegada';
    final MarkerId markerId = MarkerId(position.toString());
    final Marker marker = Marker(
        markerId: markerId,
        icon: type == MarkerType.origin ? originPin : destinyPin,
        infoWindow: InfoWindow(title: title, snippet: '$description</>$region'),
        consumeTapEvents: true,
        onTap: () => _onTapMarker(markerId, position),
        position: position);
    setState(() {
      if (markers.length > 1) {
        final Set<Marker> newMarkers = markers.map<Marker>((Marker currMarker) {
          if (currMarker.infoWindow.title == title) {
            return marker;
          }
          return currMarker;
        }).toSet();
        markers.clear();
        markers.addAll(newMarkers);
      } else {
        markers.add(marker);
      }
    });
  }

  void navigate() {
    widget.preExecute();
    final String origin = '${points.first.latitude},${points.first.longitude}';
    final List<LatLng> latLngWayPoints = points.sublist(1, points.length - 1);
    final String waypoints =
        latLngWayPoints.fold<String>('', (String acc, LatLng curr) {
      final String currLocation = '${curr.latitude},${curr.longitude}';
      if (curr == latLngWayPoints.first) return currLocation;
      return '$acc|$currLocation';
    });
    final String destiny = '${points.last.latitude},${points.last.longitude}';
    final AndroidIntent intent = AndroidIntent(
        action: 'action_view',
        data: Uri.encodeFull(
            'https://www.google.com/maps/dir/?api=1&origin=$origin&destination=$destiny&waypoints=$waypoints&travelmode=driving&dir_action=navigate'),
        package: 'com.google.android.apps.maps');
    intent.launch();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
        children: <Widget>[
              MapListener(
                  email: widget.email,
                  markers: markers,
                  points: points,
                  putMarker: putMarker,
                  preExecute: widget.preExecute,
                  setVisiblePin: (Agent agent, Polyline oldPolyline) {
                    setState(() {
                      isPinVisible = !oldPolyline.visible;
                    });
                    widget.setVisiblePin(agent, oldPolyline);
                  }),
              SearchLocation(
                  preExecute: widget.preExecute,
                  markers: markers,
                  onStartPlaceSelected: (Coordinates location,
                          String description, String region) =>
                      putMarker(LatLng(location.latitude, location.longitude),
                          description, MarkerType.origin, region),
                  onEndPlaceSelected: (Coordinates location, String description,
                          String region) =>
                      putMarker(LatLng(location.latitude, location.longitude),
                          description, MarkerType.destiny, region))
            ] +
            (points.isEmpty
                ? <Widget>[]
                : <Widget>[
                    FloatingAnimatedButton(
                      heroTag: '1',
                      bottom: isPinVisible ? 190 : 90,
                      color: Theme.of(context).primaryColor,
                      description:
                          AppLocalizations.of(context).translate('navegate'),
                      onPressed: navigate,
                      child: Icon(Icons.navigation,
                          size: 30, color: Theme.of(context).backgroundColor),
                    )
                  ]) +
            <Widget>[
              ReactiveFloatingButton(
                  bottom: isPinVisible ? 115 : 15,
                  controller: widget.controller,
                  defaultFunction: widget.changeSideMenuState,
                  length: markers.length,
                  addNewExpedient: addNewExpedient,
                  addNewAsk: addNewAsk)
            ]);
  }

  StreamSubscription<QuerySnapshot> _initAgentListener() {
    DateTime today = DateTime.now();
    today = DateTime(today.year, today.month, today.day);
    final int elapsedTime =
        DateTime.now().millisecondsSinceEpoch - today.millisecondsSinceEpoch;
    return getIt<FirebaseFirestore>()
        .collection('agent')
        .where('email', isEqualTo: widget.email)
        .where('processed', isEqualTo: true)
        .where('date', isEqualTo: today.millisecondsSinceEpoch / 1000)
        .where('askedEndAt', isGreaterThanOrEqualTo: elapsedTime / 1000)
        .orderBy('askedEndAt')
        .limit(1)
        .snapshots()
        .listen((QuerySnapshot agentSnapshot) {
      if (agentSnapshot.docs.isNotEmpty) {
        final Agent agent = Agent.fromJson(agentSnapshot.docs.first.data())!;
        if (agent.route != null) {
          final List<LatLng> points =
              agent.route!.map<LatLng>((Point point) => point.local).toList();
          setState(() {
            this.points.addAll(points);
          });
        }
      }
    });
  }

  void _onTapMarker(MarkerId markerId, LatLng position) {
    setState(() {
      if (markers.length == 2 &&
          markers.first.markerId.value == position.toString()) {
        final Marker marker = markers.last;
        markers.clear();
        markers.add(marker.copyWith(
            iconParam: originPin,
            infoWindowParam:
                marker.infoWindow.copyWith(titleParam: 'Partida ou garagem')));
      } else {
        markers.removeWhere(
            (Marker marker) => marker.markerId.value == position.toString());
      }
    });
  }
}
