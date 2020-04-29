import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_map_polyline/google_map_polyline.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:perna/constants/constants.dart';
import 'package:perna/models/agent.dart';
import 'package:perna/models/askedPoint.dart';
import 'package:perna/pages/addNewAskPage.dart';
import 'package:perna/pages/addNewExpedientPage.dart';
import 'package:perna/pages/pointDetailPage.dart';
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

class _MainPageWidgetState extends State<MainPageWidget> {
  Function cancel;
  Set<Marker> nextPlaces = Set();
  LocationData currentLocation;
  Set<Marker> markers = Set();
  Set<Polyline> polyline = Set();
  List<LatLng> routeCooords = [];
  List<LatLng> points = [];
  Completer<GoogleMapController> mapsController = Completer();
  GoogleMapPolyline googleMapPolyline = new GoogleMapPolyline(apiKey: "AIzaSyA0c4Mw7rRAiJxiTQwu6eJcoroBeWWa06w");

  final String email;
  final Function onLogout;
  final Firestore firestore;

  StreamSubscription<QuerySnapshot> agentsListener;
  bool isLoadingAgent = false;

  StreamSubscription<QuerySnapshot> askedPointsListener;
  bool isLoadingAskedPoint = false;

  _MainPageWidgetState({@required this.email, @required this.onLogout, @required this.firestore});

  StreamSubscription<QuerySnapshot> initAgentListener(){
    return firestore.collection("agent").where('email', isEqualTo: email)
      .where('processed', isEqualTo: true)
      .where('askedEndAt', isGreaterThanOrEqualTo: DateTime.now().millisecondsSinceEpoch/1000)
      .orderBy('askedEndAt').limit(1).snapshots().listen((QuerySnapshot agentSnapshot){
        if(agentSnapshot.documents.isNotEmpty){
          Agent agent = Agent.fromJson(agentSnapshot.documents.first.data);
          if(agent.route != null){
            List<LatLng> route = agent.route.map<LatLng>((point)=>point.local).toList();
            setState(() {
              this.points.addAll(route);
            });
            this.buildRouteCooords(route);
          }
        }
        setState(() {
          this.isLoadingAgent = false;
        });
    });
  }

  StreamSubscription<QuerySnapshot> initAskedPointListener(){
    return firestore.collection("askedPoint").where('email', isEqualTo: email)
      .where('processed', isEqualTo: true)
      .where('askedEndAt', isGreaterThanOrEqualTo: DateTime.now().millisecondsSinceEpoch/1000)
      .orderBy('askedEndAt').limit(1).snapshots().listen((QuerySnapshot askedPointSnapshot){
        if(askedPointSnapshot.documents.isNotEmpty){
          AskedPoint askedPoint = AskedPoint.fromJson(askedPointSnapshot.documents.first.data);
          if(askedPoint.origin != null)
            this.addNextPlace(askedPoint);
        }
        setState(() {
          this.isLoadingAskedPoint = false;
        });
    });
  }

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
    setState(() {
      this.isLoadingAskedPoint = true;
      this.isLoadingAgent = true;
      agentsListener = this.initAgentListener();
      askedPointsListener = this.initAskedPointListener();
    });
  }
  
  @override
  void dispose() {
    super.dispose();
    this.cancel();
    agentsListener.cancel();
    askedPointsListener.cancel();
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
          points: routeCooords.length >1 ? routeCooords: routeCooords, width: 6, color: Theme.of(context).primaryColor,
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
    if(locationData != null){
      final GoogleMapController controller = await this.mapsController.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(locationData.latitude, locationData.longitude),
        zoom: 20,
      )));
    }
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

  void addNextPlace(AskedPoint askedPoint) async {
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
              builder: (context) => PointDetailPage(askedPoint: askedPoint, isHome: true)
            )
          );
        },
        markerId: MarkerId(askedPoint.origin.toString()),
        icon: bitmapDescriptor,
        position: askedPoint.origin
      ));
    });
  }

  void putMarker(location) async {
    if(markers.length< 2){
      Marker marker = Marker(
        markerId: MarkerId(location.toString()),
        icon: await BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5), 
         'icons/${this.markers.length == 0 ? "bus_small.png": "red-flag_small.png"}'
        ),
        infoWindow: InfoWindow(title: this.markers.length == 0 ? "Partida ou garagem": "Chegada"),
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
          builder: (context) => AddNewAskPage(userMarkers: markers, clear: this.markers.clear)
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
          builder: (context) => AddNewExpedientPage(driverMarkers: this.markers, clear: this.markers.clear)
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
          points: this.points, //.sublist(0, this.points.length),
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

}
