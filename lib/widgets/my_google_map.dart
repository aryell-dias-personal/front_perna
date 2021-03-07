import 'dart:async';
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:perna/constants/constants.dart';
import 'package:perna/constants/mapsStyle.dart';
import 'package:perna/models/agent.dart';

class MyGoogleMap extends StatefulWidget {
  final String email;
  final FirebaseFirestore firestore;
  final Function preExecute;
  final Function(LatLng, String, MarkerType, String) putMarker;
  final List<LatLng> points;
  final Set<Marker> markers;
  final Set<Polyline> polyline;
  final Set<Marker> nextPlaces;
  final Set<Marker> watchedMarkers;
  final List<String> agentIds;

  const MyGoogleMap({
    @required this.email, 
    @required this.firestore, 
    @required this.preExecute, 
    @required this.putMarker, 
    @required this.points, 
    @required this.markers, 
    @required this.polyline, 
    @required this.nextPlaces, 
    @required this.watchedMarkers,
    @required this.agentIds
  });

  @override
  _MyGoogleMapState createState() => _MyGoogleMapState();
}

class _MyGoogleMapState extends State<MyGoogleMap> {
  Marker lastMarker;
  GoogleMapController mapsController;
  StreamSubscription<LocationData> locationStream;
  LatLng previousLatLng;
  LocationData currentLocation;

  @override
  void dispose() {
    super.dispose();
    locationStream.cancel();
  }

  onLongPress(location) async {
    widget.preExecute();
    Coordinates coordinates = Coordinates(location.latitude, location.longitude);
    List<Address> addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
    Address address = addresses.first;
    String description = address.addressLine;
    String region = '${address.subAdminArea}, ${address.adminArea}, ${address.countryName}';
    widget.putMarker(location, description, widget.markers.length == 0 ? MarkerType.origin : MarkerType.destiny, region);
  }

  onMapCreated(GoogleMapController googleMapController) async {
    if(Theme.of(context).brightness == Brightness.dark) await googleMapController.setMapStyle(darkStyle); 
    Location location = Location();
    bool enabled = await _requestLocation(location);
    if (enabled) {  
      setState(() {
        this.mapsController = googleMapController;
        locationStream = location.onLocationChanged.listen((LocationData currentLocation) {
          setState(() {
            this.currentLocation = currentLocation;
          });
          _updateLocation(currentLocation);
        });
      });
      LocationData locationData = await location.getLocation();
      _centralize(LatLng(locationData.latitude, locationData.longitude));
    }
  }
 
  double _calculateDistance(LatLng previousLatLng, LatLng newLatLng){
    int R = 6371000; // metros
    double x = (newLatLng.longitude - previousLatLng.longitude) * math.cos((previousLatLng.latitude + newLatLng.latitude) / 2);
    double y = (newLatLng.latitude - previousLatLng.latitude);
    double distance = math.sqrt(x * x + y * y) * R;
    return distance;
  }

  void _updateLocation(LocationData locationData) {
    LatLng currLatLng = LatLng(locationData.latitude, locationData.longitude);
    if(previousLatLng == null || _calculateDistance(this.previousLatLng, currLatLng)>1000){
      setState(() {
        this.previousLatLng = currLatLng;
      });
      widget.agentIds.forEach((documentID) async {
        DocumentReference ref = widget.firestore.collection('agent').doc(documentID);
        DocumentSnapshot documentSnapshot = await ref.get();
        Agent oldAgent = Agent.fromJson(documentSnapshot.data());
        DateTime askedEndAtTime = oldAgent.date.add(oldAgent.askedEndAt);
        bool endHasPassed = DateTime.now().isAfter(askedEndAtTime);
        // TODO: mudar modelo de dados do agente para não permitir alteração por parte do usuário 
        // de dados sensiveis como email do responsável e route e tal. Uma forma seria criar um model
        // `Position` que seria referenciado pelo agent, mas e a fila e o histórico?? analisar com calma, 
        // talvez um endpoint para update de queue 🤔
        if(oldAgent?.queue?.isEmpty == null || oldAgent.queue.isEmpty) {
          await ref.update({
            'position': '${locationData.latitude}, ${locationData.longitude}',
            'old': endHasPassed
          });
        } else {
          Agent newAgent = oldAgent.copyWith(
            queue: oldAgent.queue.sublist(1),
            history: [oldAgent.date] + oldAgent.history,
            date: oldAgent.queue.first,
            position: LatLng(locationData.latitude, locationData.longitude)
          );
          await ref.update(newAgent.toJson());
        }
      });
    }
  }
  
  Future<bool> _requestLocation(location) async {
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

  void _centralize(LatLng latLng) async {
    this.mapsController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: latLng,
      zoom: 20,
    )));
  }

  Future _refreshMap() async {
    PolylineId polylineId = PolylineId('MyRoute');
    Function(Polyline) findFunction = (Polyline polyline)=>polyline.polylineId==polylineId;
    if(this.mapsController!=null){
      final Brightness brightness = WidgetsBinding.instance.window.platformBrightness;
      if(brightness == Brightness.dark) {
        await this.mapsController.setMapStyle(darkStyle); 
      } else {
        await this.mapsController.setMapStyle('[]'); 
      }
    }
    if(widget.polyline.isNotEmpty){
      List<Polyline> oldPolylines = widget.polyline.where(findFunction).toList();
      Polyline oldPolyline = oldPolylines.isEmpty ? null : oldPolylines.first;
      if(oldPolyline!=null && oldPolyline.color != Theme.of(context).primaryColor){
        Polyline newPolyline= oldPolyline.copyWith(
          colorParam: Theme.of(context).primaryColor
        );
        widget.polyline.remove(oldPolyline);
        widget.polyline.add(newPolyline);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _refreshMap();
    if(widget.markers.isNotEmpty && lastMarker != widget.markers.last) {
      setState(() {
        lastMarker = widget.markers.last;
      });
      this._centralize(widget.markers.last.position);
    }
    return GoogleMap(
      onTap: (_) => this._centralize(LatLng(this.currentLocation.latitude, this.currentLocation.longitude)),
      buildingsEnabled: true,
      mapType: MapType.normal, 
      onLongPress: onLongPress,
      onCameraMove: (location){
        widget.preExecute();
      },
      polylines: widget.polyline,
      markers: widget.markers.union(widget.watchedMarkers).union(widget.nextPlaces),
      myLocationEnabled: true,
      zoomControlsEnabled: false,
      myLocationButtonEnabled: false,
      initialCameraPosition: CameraPosition(
        target: LatLng(-8.05428, -34.8813),
        zoom: 20,
      ),
      onMapCreated: this.onMapCreated,
    );
  }
}