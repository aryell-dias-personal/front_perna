import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:perna/constants/constants.dart';
import 'package:perna/constants/mapsStyle.dart';
import 'package:perna/models/agent.dart';
import 'package:perna/models/askedPoint.dart';
import 'package:perna/pages/adkedPointPage.dart';
import 'package:perna/pages/expedientPage.dart';
import 'package:perna/services/directions.dart';
import 'package:perna/store/actions.dart';
import 'package:perna/store/state.dart';
import 'package:perna/widgets/mainWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:location/location.dart';
import 'dart:async';
import 'package:toast/toast.dart';

class MainPage extends StatefulWidget {
  final String email;
  final Function onLogout;
  final Future<IdTokenResult> Function() getRefreshToken;
  final Firestore firestore;
  MainPage({@required this.email, @required this.onLogout, @required this.getRefreshToken, @required this.firestore, Key key}) : super(key: key);

  @override
  _MainPageWidgetState createState() => _MainPageWidgetState(onLogout: this.onLogout, getRefreshToken: this.getRefreshToken, email: email, firestore: firestore);
}

class _MainPageWidgetState extends State<MainPage>{
  Function cancel;
  Set<Marker> nextPlaces = Set();
  LocationData currentLocation;
  Set<Marker> markers = Set();
  Set<Polyline> polyline = Set();
  List<LatLng> routeCoords = [];
  List<LatLng> points = [];
  GoogleMapController mapsController;
  DirectionsService directionsService = DirectionsService();

  final String email;
  final Function onLogout;
  final Future<IdTokenResult> Function() getRefreshToken;
  final Firestore firestore;

  StreamSubscription<QuerySnapshot> agentsListener;
  bool isLoadingAgent = false;

  StreamSubscription<QuerySnapshot> askedPointsListener;
  bool isLoadingAskedPoint = false;

  _MainPageWidgetState({@required this.email, @required this.onLogout,  @required this.getRefreshToken, @required this.firestore});

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

  void onTapMarker(location) async {
    bool isFirst = false;
    setState(() {
      this.markers.removeWhere((marker){
        bool found = marker.markerId.value == location.toString();
        if(found) isFirst = isFirst || this.markers.first.markerId == marker.markerId;
        return found;
      });
    });
    if(this.markers.length == 1 && isFirst){
      BitmapDescriptor startBitmapDescriptor = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), 
        'icons/bus_small.png'
      );
      Marker newMarker = this.markers.first.copyWith(
        iconParam: startBitmapDescriptor,
        infoWindowParam: this.markers.first.infoWindow.copyWith(
          titleParam: "Partida ou garagem"
        )
      );
      setState(() {
        this.markers.clear();
        this.markers.add(newMarker);
      });
    }
  }

  void putMarker(location) async {
    Coordinates coordinates = new Coordinates(location.latitude, location.longitude);
    List<Address> addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
    String snippet = addresses.isNotEmpty?addresses.first.addressLine: "lat: ${location.latitude}, long: ${location.longitude}";
    if(markers.length< 2){
      bool isStart = this.markers.length == 0;
      Marker marker = Marker(
        markerId: MarkerId(location.toString()),
        icon: await BitmapDescriptor.fromAssetImage(
          ImageConfiguration(devicePixelRatio: 2.5), 
         'icons/${isStart ? "bus_small.png": "red-flag_small.png"}'
        ),
        infoWindow: InfoWindow(
          title: isStart ? "Partida ou garagem": "Chegada", 
          snippet: snippet
        ),
        consumeTapEvents: true,
        onTap: () {
          onTapMarker(location);
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
          builder: (context) => AskedPointPage(askedPoint: askedPoint, readOnly: false, clear: this.markers.clear, getRefreshToken: this.getRefreshToken)
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
          builder: (context) => ExpedientPage(agent: agent, readOnly: false, clear: this.markers.clear, getRefreshToken: this.getRefreshToken)
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
          getRefreshToken: this.getRefreshToken,
          firestore: this.firestore,
          addPolyline: this.addPolyline,
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
      List<LatLng> coords = await directionsService.getRouteBetweenCoordinates(apiKey, points);
      if (coords.isNotEmpty) {
        setState(() {
          this.routeCoords.addAll(coords);
        });
      }
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
        polylineId: polylineId, visible: false,
        points: routeCoords.length >1 ? routeCoords: routeCoords, 
        width: 6, color: Theme.of(context).primaryColor,
        startCap: Cap.roundCap, endCap: Cap.buttCap
      )
    );
  }

}
