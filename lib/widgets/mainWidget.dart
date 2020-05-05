import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:perna/widgets/AnimatedSideMenu.dart';
import 'package:perna/widgets/floatingAnimatedButton.dart';
import 'package:perna/widgets/myGoogleMap.dart';
import 'package:perna/widgets/reactiveFloatingButton.dart';
import 'package:perna/widgets/sideMenu.dart';
import 'package:perna/widgets/searchLocation.dart';
import 'package:android_intent/android_intent.dart';
import 'package:geoflutterfire/geoflutterfire.dart';

class MainWidget extends StatefulWidget {
  final String name;
  final String email;
  final String photoUrl;
  final Set<Marker> markers;
  final Set<Marker> nextPlaces;
  final Set<Polyline> polyline;
  final List<LatLng> points;
  final Firestore firestore;
  final Function logout;
  final Function onTap;
  final Function putMarker;
  final Function onMapCreated;
  final Function cancelselection;
  final Function addNewAsk;
  final Function addNewExpedient;
  final Function centralize;

  const MainWidget({
    Key key, 
    @required this.photoUrl, 
    @required this.firestore, 
    @required this.name,
    @required this.email, 
    @required this.logout,
    @required this.onTap,
    @required this.putMarker,
    @required this.onMapCreated,
    @required this.polyline, 
    @required this.markers,
    @required this.nextPlaces,
    @required this.cancelselection,
    @required this.addNewExpedient, 
    @required this.centralize, 
    @required this.addNewAsk,
    @required this.points
  }) : super(key: key);

  @override
  _MainWidgetState createState() {
    return _MainWidgetState(
      firestore: this.firestore,
      photoUrl: this.photoUrl, 
      email: this.email, 
      name: this.name, 
      logout: this.logout,
      onTap: this.onTap,
      putMarker: this.putMarker,
      onMapCreated: this.onMapCreated,
      polyline: this.polyline,
      points: this.points,
      markers: this.markers,
      centralize: this.centralize,
      cancelselection: this.cancelselection,
      addNewExpedient: this.addNewExpedient, 
      addNewAsk: this.addNewAsk,
      nextPlaces: this.nextPlaces
    );
  }
}

class _MainWidgetState extends State<MainWidget> with SingleTickerProviderStateMixin {
  final String name;
  final String email;
  final String photoUrl;
  final Set<Polyline> polyline;
  final Set<Marker> markers;
  final Set<Marker> nextPlaces;
  final List<LatLng> points;
  final Firestore firestore;
  final Function logout;
  final Function onTap;
  final Function putMarker;
  final Function onMapCreated;
  final Function cancelselection;
  final Function addNewAsk;
  final Function addNewExpedient;
  final Function centralize;
  final Geoflutterfire geo = Geoflutterfire();

  bool isOpen = false;
  AnimationController controller;

  _MainWidgetState({
    @required this.photoUrl, 
    @required this.firestore, 
    @required this.name,
    @required this.email, 
    @required this.logout,
    @required this.onTap,
    @required this.putMarker,
    @required this.nextPlaces,
    @required this.onMapCreated,
    @required this.polyline, 
    @required this.markers,
    @required this.cancelselection,
    @required this.addNewExpedient, 
    @required this.centralize, 
    @required this.addNewAsk,
    @required this.points
  });

  @override
  void initState() {
    super.initState();
    setState(() {
      this.controller = AnimationController(duration: const Duration(milliseconds: 200), vsync:this);
    });
  }

  // void _addGeoPoint(LatLng latLng) {
  //   GeoFirePoint geoFirePoint = geo.point(latitude: latLng.latitude, longitude: latLng.longitude);
  //   this.firestore.collection('locations')
  //       .add({'name': 'random name', 'position': geoFirePoint.data}).then((_) {
  //     print('added ${geoFirePoint.hash} successfully');
  //   });
  // }

  _openSideMenu(){
    setState(() {
      isOpen =! isOpen;
      isOpen ? controller.forward() : controller.reverse();
    });
  }

  _navigate(){
    if(this.isOpen) _openSideMenu();
    String origin = "${this.points.first.latitude},${this.points.first.longitude}";
    List<LatLng> latLngWayPoints = this.points.sublist(1,this.points.length-1);
    String waypoints = latLngWayPoints.fold<String>("",(String acc, LatLng curr){
      String currLocation = "${curr.latitude},${curr.longitude}";
      if(curr == latLngWayPoints.first){
        return "$currLocation";
      }
      return "$acc|$currLocation";
    });
    String destiny = "${this.points.last.latitude},${this.points.last.longitude}";
    final AndroidIntent intent = new AndroidIntent(
      action: 'action_view',
      data: Uri.encodeFull(
        "https://www.google.com/maps/dir/?api=1&origin=$origin&destination=$destiny&waypoints=$waypoints&travelmode=driving&dir_action=navigate"),
      package: 'com.google.android.apps.maps'
    );
    intent.launch();
  }

  Future _addMarkerWithSearch(location, String description, int type) async {
    if(this.isOpen) _openSideMenu();
    LatLng position = LatLng(location.lat, location.lng);
    BitmapDescriptor bitmapDescriptor = await BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5), 
      type == 0 ? 'icons/bus_small.png' : 'icons/red-flag_small.png'
    );
    setState(() {
      this.markers.removeWhere((marker){
          return  marker.infoWindow.title == (type == 0 ? "Partida ou garagem" : "Chegada") ;
      });
      this.markers.add(
        Marker(markerId: MarkerId(position.toString()),
          icon: bitmapDescriptor,
          infoWindow: InfoWindow(title: type == 0 ? "Partida ou garagem": "Chegada", snippet: description),
          consumeTapEvents: true,
          onTap: (){
            setState(() {
              this.markers.removeWhere((marker){
                return marker.markerId.value == position.toString();
              });
              if(this.markers.length == 1){
                LatLng postion = this.markers.first.position;
                this.markers.clear();
                putMarker(postion);
              }
            });
          }, 
          position: position
        )
      );
      this.centralize(position);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          Stack(
            children: <Widget>[
              MyGoogleMap(
                onTap: this.onTap,
                polyline:this.polyline,
                onLongPress: this.putMarker,
                onMapCreated: this.onMapCreated,
                markers: this.markers.union(this.nextPlaces),
                preExecute: (){ if(this.isOpen) _openSideMenu(); },
              ),
              SearchLocation(
                preExecute: (){ if(this.isOpen) _openSideMenu(); },
                markers: this.markers,
                onStartPlaceSelected: (location, description) async {
                  await _addMarkerWithSearch(location, description, 0);
                },
                onEndPlaceSelected: (location, description) async {
                  await _addMarkerWithSearch(location, description, 1);
                }
              )
            ]  + (this.points==null || this.points.length <= 1 ? [] : [
              FloatingAnimatedButton(
                heroTag: "1",
                bottom: 90,
                color: Theme.of(context).primaryColor,
                child: Icon(
                  Icons.navigation, size: 30,
                  color: Colors.white,
                ),
                description: "Navegar",
                onPressed: this._navigate,
              )
            ]) + [
              ReactiveFloatingButton(
                controller:this.controller,
                defaultFunction:this._openSideMenu,
                length:this.markers.length,
                addNewExpedient:this.addNewExpedient,
                addNewAsk:this.addNewAsk
              )
            ]
          ),
          AnimatedSideMenu(
            isOpen: this.isOpen,
            sideMenu: SideMenu(
              email: this.email, 
              name: this.name, 
              logout: this.logout, 
              photoUrl: this.photoUrl,
              textColor: Theme.of(context).primaryColor
            )
          )
        ],
      )
    );
  }
}
