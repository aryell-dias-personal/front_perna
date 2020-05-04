import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:perna/widgets/floatingAnimatedButton.dart';
import 'package:perna/widgets/sideMenu.dart';
import 'package:perna/widgets/searchLocation.dart';
import 'package:android_intent/android_intent.dart';

class MainWidget extends StatelessWidget {
  final String photoUrl;
  final String name;
  final String email;
  final Function logout;
  final Set<Marker> nextPlaces;
  final Function onTap;
  final Function putMarker;
  final Function onMapCreated;
  final Set<Polyline> polyline;
  final List<LatLng> points;
  final Set<Marker> markers;
  final Function cancelselection;
  final Set<Circle> circles;
  final Function addNewAsk;
  final Function addNewExpedient;
  final Function centralize;

  const MainWidget({
    Key key, 
    @required this.photoUrl, 
    @required this.name,
    @required this.email, 
    @required this.logout,
    @required this.onTap,
    @required this.putMarker,
    @required this.onMapCreated,
    @required this.polyline, 
    @required this.nextPlaces,
    @required this.markers,
    this.circles,
    @required this.cancelselection,
    @required this.addNewExpedient, 
    @required this.centralize, 
    @required this.addNewAsk,
    @required this.points
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return _MainWidget(
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
      circles: this.circles,
      centralize: this.centralize,
      cancelselection: this.cancelselection,
      addNewExpedient: this.addNewExpedient,
      addNewAsk: this.addNewAsk,
      nextPlaces: this.nextPlaces
    );
  }
}

class _MainWidget extends StatefulWidget {
  final String name;
  final String email;
  final Function logout;
  final String photoUrl;
  final Set<Marker> nextPlaces;
  final Function onTap;
  final Function putMarker;
  final Function onMapCreated;
  final Set<Polyline> polyline;
  final List<LatLng> points;
  final Set<Marker> markers;
  final Function cancelselection;
  final Set<Circle> circles;
  final Function addNewAsk;
  final Function addNewExpedient;
  final Function centralize;

  const _MainWidget({
    Key key, 
    @required this.photoUrl, 
    @required this.name,
    @required this.email, 
    @required this.logout,
    @required this.onTap,
    @required this.putMarker,
    @required this.onMapCreated,
    @required this.polyline, 
    @required this.markers,
    this.circles,
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
      circles: this.circles,
      centralize: this.centralize,
      cancelselection: this.cancelselection,
      addNewExpedient: this.addNewExpedient, 
      addNewAsk: this.addNewAsk,
      nextPlaces: this.nextPlaces
    );
  }
}

class _MainWidgetState extends State<_MainWidget> with SingleTickerProviderStateMixin {
  final String name;
  final String email;
  final Function logout;
  final String photoUrl;
  final Function onTap;
  final Function putMarker;
  final Function onMapCreated;
  final Set<Polyline> polyline;
  final List<LatLng> points;
  final Set<Marker> markers;
  final Set<Marker> nextPlaces;
  final Set<Circle> circles;
  final Function cancelselection;
  final Function addNewAsk;
  final Function addNewExpedient;
  final Function centralize;

  bool isOpen = false;
  double screemWidth, screemHeight;
  AnimationController controller;

  _MainWidgetState({
    @required this.photoUrl, 
    @required this.name,
    @required this.email, 
    @required this.logout,
    @required this.onTap,
    @required this.putMarker,
    @required this.nextPlaces,
    @required this.onMapCreated,
    @required this.polyline, 
    @required this.markers,
    this.circles,
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

  openSideMenu(){
    setState(() {
      isOpen =! isOpen;
      isOpen ? controller.forward() : controller.reverse();
    });
  }

  navigate(){
    if(this.isOpen) openSideMenu();
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

  Future addMarkerWithSearch(location, String description, int type) async {
    if(this.isOpen) openSideMenu();
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

  FloatingAnimatedButton getFloatingAnimatedButton(){
    Color color = Colors.white;
    Widget icon = AnimatedIcon(
      size: 30, icon: AnimatedIcons.menu_home,
      color: Theme.of(context).primaryColor,
      progress: this.controller
    );
    String description = "Abrir Menu";
    Function() onPressed =  this.openSideMenu;
    if(this.markers.length != 0){
      color = Colors.greenAccent;
      if(this.markers.length == 1){
        icon = Icon(Icons.work, color: Colors.white);
        description = "Adicionar Expediente";
        onPressed = this.addNewExpedient;
      }else{
        icon = Icon(Icons.scatter_plot, color: Colors.white);
        description = "Adicionar Pedido";
        onPressed = this.addNewAsk;
      }
    }
    return FloatingAnimatedButton(
      heroTag: "2",
      bottom: 15,
      color: color,
      child: icon,
      description: description,
      onPressed: onPressed,
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    screemHeight = size.height;
    screemWidth = size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          Stack(
            children: <Widget>[
              GoogleMap(
                onTap: this.onTap,
                buildingsEnabled: true,
                circles: this.circles, 
                mapType: MapType.normal, 
                onLongPress: (position){
                  if(this.isOpen) openSideMenu();
                  this.putMarker(position);
                },
                onCameraMove: (location){
                  if(this.isOpen) openSideMenu();
                },
                polylines: this.polyline,
                markers: this.markers.union(this.nextPlaces),
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                initialCameraPosition: CameraPosition(
                  target: LatLng(-8.05428, -34.8813),
                  zoom: 20,
                ),
                onMapCreated: this.onMapCreated,
              ),
              SearchLocation(
                preExecute: (){
                  if(this.isOpen) openSideMenu();
                },
                markers: this.markers,
                onStartPlaceSelected: (location, description) async {
                  await addMarkerWithSearch(location, description, 0);
                },
                onEndPlaceSelected: (location, description) async {
                  await addMarkerWithSearch(location, description, 1);
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
                onPressed: this.navigate,
              )
            ]) + [
              this.getFloatingAnimatedButton()
            ]
          ),
          AnimatedPositioned(
            duration: Duration(milliseconds: 200),
            top: 0,
            bottom: 0,
            left: !isOpen ? -screemWidth/1.7 : 0,
            right: !isOpen ? screemWidth : screemWidth/1.7,
            child: Material(
              color: Colors.white,
              clipBehavior: Clip.antiAlias,
              borderRadius: BorderRadius.only(bottomRight: Radius.circular(30), topRight: Radius.circular(30)),
              elevation: 8,
              child: SideMenu(
                email: this.email, 
                name: this.name, 
                logout: this.logout, 
                photoUrl: this.photoUrl,
                textColor: Theme.of(context).primaryColor
              )
            ) 
          )
        ],
      )
    );
  }
}
