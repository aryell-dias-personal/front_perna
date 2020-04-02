import 'package:google_map_polyline/google_map_polyline.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:perna/constants/constants.dart';
import 'package:perna/models/mapsData.dart';
import 'package:perna/pages/addNewAskPage.dart';
import 'package:perna/pages/addNewExpedientPage.dart';
import 'package:perna/services/maps.dart';
import 'package:perna/store/actions.dart';
import 'package:perna/store/state.dart';
import 'package:perna/widgets/mainWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:location/location.dart';
import 'dart:async';

import 'package:toast/toast.dart';

class MainPage extends StatelessWidget {

  final String email;
  final Function onLogout;
  MainPage({@required this.email, @required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return MainPageWidget(onLogout: onLogout, email: email);
  }
}

class MainPageWidget extends StatefulWidget {

  final String email;
  final Function onLogout;
  MainPageWidget({@required this.email, @required this.onLogout, Key key}) : super(key: key);

  @override
  _MainPageWidgetState createState() => _MainPageWidgetState(onLogout: this.onLogout, email: email);
}

class _MainPageWidgetState extends State<MainPageWidget> {
  Function cancel;
  LatLng nextPlace;
  LocationData currentLocation;
  Set<Marker> markers = Set();
  Set<Polyline> polyline = Set();
  List<LatLng> routeCooords = [];
  Completer<GoogleMapController> mapsController = Completer();
  GoogleMapPolyline googleMapPolyline = new GoogleMapPolyline(apiKey: "AIzaSyA0c4Mw7rRAiJxiTQwu6eJcoroBeWWa06w");

  final String email;
  final Function onLogout;
  _MainPageWidgetState({@required this.email, @required this.onLogout});

  buildRouteCooords(List<LatLng> points) async {
    if(points.length >= 2){
      List<LatLng> coords = await googleMapPolyline.getCoordinatesWithLocation(
        destination: points[1],
        origin: points.first,
        mode:  RouteMode.driving
      );
      setState(() {
        this.routeCooords.addAll(coords);
      });
      await this.buildRouteCooords(points.sublist(1));
    }
  }

  @override
  void initState() {
    super.initState();
    MapsService mapsService = MapsService();
    mapsService.getMapsData(this.email).then((MapsData mapsData){
      if(mapsData != null){
        if(mapsData.route != null)
          this.buildRouteCooords(mapsData.route);
        if(mapsData.nextPlace != null)
          this.nextPlace = mapsData.nextPlace;
      }
    });
  }

  void onMapCreated(GoogleMapController googleMapController) async {
    Location location = Location();
    bool enabled = await requestLocation(location);
    if (enabled) {  
      setState(() {
        this.mapsController.complete(googleMapController);
        this.polyline.add(Polyline(
          geodesic: true,
          jointType: JointType.round,
          polylineId: PolylineId(routeCooords.toString()), visible: true,
          points: routeCooords.length >1 ? routeCooords: routeCooords, width: 3, color: Theme.of(context).primaryColor,
          startCap: Cap.roundCap, endCap: Cap.buttCap
        ));
        this.cancel = location.onLocationChanged().listen((LocationData currentLocation) {
          setState(() {
            this.currentLocation = currentLocation;
          });
        }).cancel;
      });
      centralize(await location.getLocation());
    }
  }

  void centralize(LocationData locationData) async {
    final GoogleMapController controller = await this.mapsController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(locationData.latitude, locationData.longitude),
      zoom: 20,
    )));
  }

  Future<bool> requestLocation(location) async {
    bool _serviceEnabled;
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
    }
    PermissionStatus _permissionGranted;
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.DENIED) {
      _permissionGranted = await location.requestPermission();
    }
    return _serviceEnabled && _permissionGranted != PermissionStatus.DENIED;
  }

  @override
  void dispose() {
    super.dispose();
    this.cancel();
  }

  void putMarker(location) {
    if(markers.length< 2){
      setState(() {
        this.markers.add(Marker(
          markerId: MarkerId(location.toString()),
          draggable: true,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            this.markers.length == 0 ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueRed
          ),
          consumeTapEvents: true,
          onTap: (){
            setState(() {
              this.markers.removeWhere((marker){
                return marker.markerId.value == location.toString();
              });
              if(this.markers.length == 1){
                LatLng postion = this.markers.first.position;
                this.markers.clear();
                putMarker(postion);
              }
            });
          }, 
          position: location
        ));
      });
    } else {
      Toast.show(
        "Você não pode marcar mais de dois pontos", context, 
        backgroundColor: Colors.redAccent, 
        duration: 3
      );
    }
  }

  List<PopupMenuEntry<MenuOption>> menuBuilder(BuildContext context) {
    return <PopupMenuEntry<MenuOption>>[
      const PopupMenuItem<MenuOption>(
          value: MenuOption.clear, child: Text('Limpar Mapa')),
      const PopupMenuItem<MenuOption>(
          value: MenuOption.logout, child: Text('Deslogar'))
    ];
  }

  void addNewAsk() {
    if(this.markers.length == 2){
      Navigator.push(context, 
        MaterialPageRoute(
          builder: (context) => AddNewAskPage()
        )
      );
    } else {
      Toast.show(
        "Você deve marcar dois pontos para esta ação", context, 
        backgroundColor: Colors.redAccent, 
        duration: 3
      );
    }
  }

  void addNewExpedient(){
    if(this.markers.length == 1){
      Navigator.push(context, 
        MaterialPageRoute(
          builder: (context) => AddNewExpedientPage()
        )
      );
    } else {
      Toast.show(
        "Você deve marcar um ponto para esta ação", context, 
        backgroundColor: Colors.redAccent, 
        duration: 3
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<StoreState, Map<String, dynamic>>(
      converter: (store) {
        return {
          'logoutFunction': () {
            this.onLogout();
            store.dispatch(Logout());
          },
          'photoUrl':store.state.user?.photoUrl,
          'email':store.state.user?.email,
          'name':store.state.user?.name
        };
      },
      builder: (context, resources) {
        return MainWidget(
          addNewAsk: this.addNewAsk,
          addNewExpedient: this.addNewExpedient,
          email: resources['email'],
          name: resources['name'],
          logout: resources['logoutFunction'],
          photoUrl: resources['photoUrl'],
          onTap: (location) => centralize(this.currentLocation),
          putMarker: this.putMarker,
          cancelselection: (){
            setState(() {
              this.markers.clear();
            });
          },
          onMapCreated: this.onMapCreated,
          polyline: this.polyline,
          markers: nextPlace != null ? this.markers.union([
              Marker(
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
                markerId: MarkerId(nextPlace.toString()),
                position: nextPlace
              )
          ].toSet()) : this.markers
        );
      }
    );
  }

}
