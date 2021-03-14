import 'dart:async';
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:perna/constants/constants.dart';
import 'package:perna/constants/maps_style.dart';
import 'package:perna/main.dart';
import 'package:perna/models/agent.dart';

class MyGoogleMap extends StatefulWidget {
  const MyGoogleMap(
      {required this.email,
      required this.preExecute,
      required this.putMarker,
      required this.points,
      required this.markers,
      required this.polyline,
      required this.nextPlaces,
      required this.watchedMarkers,
      required this.agentIds});

  final String email;
  final Function preExecute;
  final Function(LatLng, String, MarkerType, String) putMarker;
  final List<LatLng> points;
  final Set<Marker> markers;
  final Set<Polyline> polyline;
  final Set<Marker> nextPlaces;
  final Set<Marker> watchedMarkers;
  final List<String> agentIds;

  @override
  _MyGoogleMapState createState() => _MyGoogleMapState();
}

class _MyGoogleMapState extends State<MyGoogleMap> {
  late StreamSubscription<LocationData> locationStream;
  late LocationData currentLocation;
  GoogleMapController? mapsController;
  Marker? lastMarker;
  LatLng? previousLatLng;

  @override
  void dispose() {
    super.dispose();
    locationStream.cancel();
  }

  Future<void> onLongPress(LatLng location) async {
    widget.preExecute();
    final Coordinates coordinates =
        Coordinates(location.latitude, location.longitude);
    final List<Address> addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    final Address address = addresses.first;
    final String? description = address.addressLine;
    final String region =
        '${address.subAdminArea}, ${address.adminArea}, ${address.countryName}';
    widget.putMarker(
        location,
        description ?? region,
        widget.markers.isEmpty ? MarkerType.origin : MarkerType.destiny,
        region);
  }

  Future<void> onMapCreated(GoogleMapController googleMapController) async {
    if (Theme.of(context).brightness == Brightness.dark) {
      await googleMapController.setMapStyle(darkStyle);
    }
    final Location location = Location();
    final bool enabled = await _requestLocation(location);
    if (enabled) {
      setState(() {
        mapsController = googleMapController;
        locationStream =
            location.onLocationChanged.listen((LocationData currentLocation) {
          setState(() {
            this.currentLocation = currentLocation;
          });
          _updateLocation(currentLocation);
        });
      });
      final LocationData locationData = await location.getLocation();
      if (locationData.latitude != null && locationData.longitude != null) {
        _centralize(LatLng(locationData.latitude!, locationData.longitude!));
      }
    }
  }

  double _calculateDistance(LatLng previousLatLng, LatLng newLatLng) {
    const int R = 6371000; // metros
    final double x = (newLatLng.longitude - previousLatLng.longitude) *
        math.cos((previousLatLng.latitude + newLatLng.latitude) / 2);
    final double y = newLatLng.latitude - previousLatLng.latitude;
    final double distance = math.sqrt(x * x + y * y) * R;
    return distance;
  }

  Future<void> _updateLocation(LocationData locationData) async {
    if (locationData.latitude == null || locationData.longitude == null) {
      return;
    }
    final LatLng currLatLng =
        LatLng(locationData.latitude!, locationData.longitude!);
    if (previousLatLng == null ||
        _calculateDistance(previousLatLng!, currLatLng) > 1000) {
      setState(() {
        previousLatLng = currLatLng;
      });
      for (final String documentID in widget.agentIds) {
        final DocumentReference ref =
            getIt<FirebaseFirestore>().collection('agent').doc(documentID);
        final DocumentSnapshot documentSnapshot = await ref.get();
        final Agent? oldAgent = Agent.fromJson(documentSnapshot.data());
        final DateTime? askedEndAtTime =
            oldAgent?.date!.add(oldAgent.askedEndAt!);
        final bool endHasPassed =
            askedEndAtTime != null && DateTime.now().isAfter(askedEndAtTime);
        if (oldAgent?.queue?.isEmpty == null ||
            oldAgent!.queue!.isEmpty ||
            !endHasPassed) {
          await ref.update(<String, dynamic>{
            'position': '${locationData.latitude}, ${locationData.longitude}',
            'old': endHasPassed
          });
        } else {
          final Agent newAgent = oldAgent.copyWith(
              queue: oldAgent.queue!.sublist(1),
              history: <DateTime>[oldAgent.date!] +
                  (oldAgent.history ?? <DateTime>[]),
              date: oldAgent.queue!.first,
              position:
                  LatLng(locationData.latitude!, locationData.longitude!));
          await ref.update(newAgent.toJson() as Map<String, dynamic>);
        }
      }
    }
  }

  Future<bool> _requestLocation(Location location) async {
    bool _serviceEnabled;
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
    }
    PermissionStatus _permissionGranted;
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
    }
    return _serviceEnabled && _permissionGranted != PermissionStatus.denied;
  }

  Future<void> _centralize(LatLng latLng) async {
    if (mapsController != null) {
      mapsController!
          .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: latLng,
        zoom: 20,
      )));
    }
  }

  Future<void> _refreshMap() async {
    final PolylineId polylineId = PolylineId('MyRoute');
    bool findFunction(Polyline polyline) => polyline.polylineId == polylineId;
    if (mapsController != null) {
      final Brightness brightness =
          WidgetsBinding.instance?.window.platformBrightness ??
              Brightness.light;
      if (brightness == Brightness.dark) {
        await mapsController!.setMapStyle(darkStyle);
      } else {
        await mapsController!.setMapStyle('[]');
      }
    }
    if (widget.polyline.isNotEmpty) {
      final List<Polyline> oldPolylines =
          widget.polyline.where(findFunction).toList();
      final Polyline? oldPolyline =
          oldPolylines.isEmpty ? null : oldPolylines.first;
      if (oldPolyline != null &&
          oldPolyline.color != Theme.of(context).primaryColor) {
        final Polyline newPolyline =
            oldPolyline.copyWith(colorParam: Theme.of(context).primaryColor);
        widget.polyline.remove(oldPolyline);
        widget.polyline.add(newPolyline);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _refreshMap();
    if (widget.markers.isNotEmpty && lastMarker != widget.markers.last) {
      setState(() {
        lastMarker = widget.markers.last;
      });
      _centralize(widget.markers.last.position);
    }
    return GoogleMap(
      onTap: (_) {
        if (currentLocation.latitude != null &&
            currentLocation.longitude != null) {
          _centralize(
              LatLng(currentLocation.latitude!, currentLocation.longitude!));
        }
      },
      onLongPress: onLongPress,
      onCameraMove: (CameraPosition location) {
        widget.preExecute();
      },
      polylines: widget.polyline,
      markers:
          widget.markers.union(widget.watchedMarkers).union(widget.nextPlaces),
      myLocationEnabled: true,
      zoomControlsEnabled: false,
      myLocationButtonEnabled: false,
      initialCameraPosition: const CameraPosition(
        target: LatLng(-8.05428, -34.8813),
        zoom: 20,
      ),
      onMapCreated: onMapCreated,
    );
  }
}
