import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_map_polyline/google_map_polyline.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:perna/constants/mapsStyle.dart';
import 'package:perna/models/agent.dart';
import 'package:perna/models/askedPoint.dart';
import 'package:perna/pages/adkedPointPage.dart';
import 'package:perna/pages/expedientPage.dart';
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
  final Firestore firestore;
  MainPage({@required this.email, @required this.onLogout, @required this.firestore});

  @override
  Widget build(BuildContext context) {
    return MainPageWidget(onLogout: onLogout, email: email, firestore: firestore);
  }
}

class MainPageWidget extends StatefulWidget {

  final String email;
  final Function onLogout;
  final Firestore firestore;
  MainPageWidget({@required this.email, @required this.onLogout, @required this.firestore, Key key}) : super(key: key);

  @override
  _MainPageWidgetState createState() => _MainPageWidgetState(onLogout: this.onLogout, email: email, firestore: firestore);
}

class _MainPageWidgetState extends State<MainPageWidget>{
  Function cancel;
  Set<Marker> nextPlaces = Set();
  LocationData currentLocation;
  Set<Marker> markers = Set();
  Set<Polyline> polyline = Set();
  List<LatLng> routeCoords = [];
  List<LatLng> points = [];
  GoogleMapController mapsController;
  final Geolocator _geolocator = Geolocator();
  GoogleMapPolyline googleMapPolyline = new GoogleMapPolyline(apiKey: "AIzaSyA0c4Mw7rRAiJxiTQwu6eJcoroBeWWa06w");

  final String email;
  final Function onLogout;
  final Firestore firestore;

  StreamSubscription<QuerySnapshot> agentsListener;
  bool isLoadingAgent = false;

  StreamSubscription<QuerySnapshot> askedPointsListener;
  bool isLoadingAskedPoint = false;

  _MainPageWidgetState({@required this.email, @required this.onLogout, @required this.firestore});

  @override
  void initState() {
    super.initState();
    setState(() {
      this.isLoadingAskedPoint = true;
      this.isLoadingAgent = true;
      this.agentsListener = this._initAgentListener();
      this.askedPointsListener = this._initAskedPointListener();
    });
  }
  
  @override
  void dispose() {
    super.dispose();
    this.cancel();
    agentsListener.cancel();
    askedPointsListener.cancel();
  }

  Future showInfoWindow(MarkerId markerId) async {
    if(await this.mapsController.isMarkerInfoWindowShown(markerId)) 
      return await this.mapsController.hideMarkerInfoWindow(markerId);
    return await this.mapsController.showMarkerInfoWindow(markerId);
  }

  addPolyline(List<LatLng> points, String name) async {
    await this._buildRouteCoords(points);
    PolylineId polylineId = PolylineId(name);
    this.polyline.removeWhere((Polyline polyline)=>polyline.polylineId==polylineId);
    this.polyline.add(
      Polyline(
        geodesic: true,
        jointType: JointType.round,
        polylineId: polylineId, visible: false,
        points: routeCoords.length >1 ? routeCoords: routeCoords, 
        width: 6, color: Colors.amber,
        startCap: Cap.roundCap, endCap: Cap.buttCap
      )
    );
  }

  void onMapCreated(GoogleMapController googleMapController) async {
    if(Theme.of(context).brightness == Brightness.dark) await googleMapController.setMapStyle(darkStyle); 
    Location location = Location();
    bool enabled = await _requestLocation(location);
    if (enabled) {  
      setState(() {
        this.mapsController = googleMapController;
        this.cancel = location.onLocationChanged().listen((LocationData currentLocation) {
          setState(() {
            this.currentLocation = currentLocation;
          });
        }).cancel;
      });
      centralize(await location.getLocation());
    }
  }

  void centralizeLatLng(LatLng latLng) async {
    this.mapsController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: latLng,
      zoom: 20,
    )));
  }

  void centralize(LocationData locationData) async {
    if(locationData != null){
      this.mapsController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(locationData.latitude, locationData.longitude),
        zoom: 20,
      )));
    }
  }

  void putMarker(location) async {
    List<Placemark> placeMarkers = await _geolocator.placemarkFromCoordinates(location.latitude, location.longitude);
    Placemark placemark = placeMarkers.first;
    if(markers.length< 2){
      Marker marker = Marker(
        markerId: MarkerId(location.toString()),
        icon: await BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5), 
         'icons/${this.markers.length == 0 ? "bus_small.png": "red-flag_small.png"}'
        ),
        infoWindow: InfoWindow(title: this.markers.length == 0 ? "Partida ou garagem": "Chegada", snippet: _placemarkToString(placemark)),
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
      );
      setState(() {
        this.markers.add(marker);
      });
    } else {
      Toast.show(
        "Você não pode marcar mais de dois pontos", context, 
        backgroundColor: Colors.redAccent, 
        duration: 3
      );
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
          builder: (context) => AskedPointPage(askedPoint: askedPoint, readOnly: false, clear: this.markers.clear)
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
      Agent agent = Agent(
        friendlyGarage: markers.first.infoWindow.snippet,
        garage: markers.first.position
      );
      Navigator.push(context, 
        MaterialPageRoute(
          builder: (context) => ExpedientPage(agent: agent, readOnly: false, clear: this.markers.clear)
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
    _refreshMap().catchError((error){
      print(error);
    });
    return StoreConnector<StoreState, Map<String, dynamic>>(
      converter: (store) {
        return {
          'logoutFunction': () {
            this.onLogout(user: store.state.user, messagingToken: store.state.messagingToken);
            store.dispatch(Logout());
          },
          'photoUrl':store.state.user?.photoUrl,
          'email':store.state.user?.email,
          'name':store.state.user?.name
        };
      },
      builder: (context, resources) {
        return MainWidget(
          firestore: this.firestore,
          addPolyline: this.addPolyline,
          showInfoWindow: this.showInfoWindow,
          points: this.points,
          centralize: this.centralizeLatLng,
          nextPlaces: this.nextPlaces,
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
          markers: this.markers
        );
      }
    );
  }

  Future _refreshMap() async {
    PolylineId polylineId = PolylineId("MyRoute");
    Function(Polyline) findFunction = (Polyline polyline)=>polyline.polylineId==polylineId;
    if(this.mapsController!=null){
      final Brightness brightness = WidgetsBinding.instance.window.platformBrightness;
      if(brightness == Brightness.dark) {
        await this.mapsController.setMapStyle(darkStyle); 
      } else {
        await this.mapsController.setMapStyle("[]"); 
      }
    }
    if(this.polyline.isNotEmpty){
      Polyline oldPolyline = this.polyline.firstWhere(findFunction);
      if(oldPolyline!=null && oldPolyline.color != Theme.of(context).primaryColor){
        Polyline newPolyline= oldPolyline.copyWith(
          colorParam: Theme.of(context).primaryColor
        );
        this.polyline.remove(oldPolyline);
        this.polyline.add(newPolyline);
      }
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
    if (_permissionGranted == PermissionStatus.DENIED) {
      _permissionGranted = await location.requestPermission();
    }
    return _serviceEnabled && _permissionGranted != PermissionStatus.DENIED;
  }

  void _addNextPlace(AskedPoint askedPoint) async {
    BitmapDescriptor bitmapDescriptor = await BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5), 
      'icons/bell_small.png'
    );
    setState(() {
      this.nextPlaces.add(Marker(
        consumeTapEvents: true,
        infoWindow: InfoWindow(title: "Você terá que estar aqui"),
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

  String _placemarkToString(Placemark placemark){
    List<String> info = [
      placemark.administrativeArea, 
      placemark.subAdministrativeArea, 
      placemark.subLocality, placemark.thoroughfare, 
      placemark.subThoroughfare
    ];
    String result = info.fold("", (String acc, String curr){
      if(curr.trim() == "") return acc;
      return "$acc$curr, ";
    });
    return result.substring(0, result.length-2);
  }

  StreamSubscription<QuerySnapshot> _initAgentListener(){
    return firestore.collection("agent").where('email', isEqualTo: email)
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
            _addMyRoutePolyline(points);
          }
        }
        setState(() {
          this.isLoadingAgent = false;
        });
    });
  }

  StreamSubscription<QuerySnapshot> _initAskedPointListener(){
    return firestore.collection("askedPoint").where('email', isEqualTo: email)
      .where('processed', isEqualTo: true)
      .where('askedEndAt', isGreaterThanOrEqualTo: DateTime.now().millisecondsSinceEpoch/1000)
      .orderBy('askedEndAt').limit(1).snapshots().listen((QuerySnapshot askedPointSnapshot){
        if(askedPointSnapshot.documents.isNotEmpty){
          AskedPoint askedPoint = AskedPoint.fromJson(askedPointSnapshot.documents.first.data);
          if(askedPoint.origin != null)
            this._addNextPlace(askedPoint);
        }
        setState(() {
          this.isLoadingAskedPoint = false;
        });
    });
  }

  _buildRouteCoords(List<LatLng> points) async {
    if(points.length >= 2){
      List<LatLng> coords = await googleMapPolyline.getCoordinatesWithLocation(
        destination: points[1],
        origin: points.first,
        mode:  RouteMode.driving
      );
      setState(() {
        this.routeCoords.addAll(coords);
      });
      await this._buildRouteCoords(points.sublist(1));
    }
  }  

  _addMyRoutePolyline(List<LatLng> points) async {
    await this._buildRouteCoords(points);
    PolylineId polylineId = PolylineId("MyRoute");
    this.polyline.removeWhere((Polyline polyline)=>polyline.polylineId==polylineId);
    this.polyline.add(
      Polyline(
        geodesic: true,
        jointType: JointType.round,
        polylineId: polylineId, visible: true,
        points: routeCoords.length >1 ? routeCoords: routeCoords, 
        width: 6, color: Theme.of(context).primaryColor,
        startCap: Cap.roundCap, endCap: Cap.buttCap
      )
    );
  }

}
