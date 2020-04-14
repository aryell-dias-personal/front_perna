import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:perna/pages/helpPage.dart';
import 'package:perna/pages/historyPage.dart';
import 'package:perna/store/state.dart';
import 'package:perna/widgets/sideMenuButton.dart';

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
  final Set<Marker> markers;
  final Function cancelselection;
  final Set<Circle> circles;
  final Function addNewAsk;
  final Function addNewExpedient;

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
    @required this.circles,
    @required this.cancelselection,
    @required this.addNewExpedient, 
    @required this.addNewAsk
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
      markers: this.markers,
      circles: this.circles,
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
  final Set<Marker> markers;
  final Function cancelselection;
  final Set<Circle> circles;
  final Function addNewAsk;
  final Function addNewExpedient;

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
    @required this.circles,
    @required this.nextPlaces,
    @required this.cancelselection,
    @required this.addNewExpedient, 
    @required this.addNewAsk
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
      markers: this.markers,
      circles: this.circles,
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
  final Set<Marker> markers;
  final Set<Marker> nextPlaces;
  final Set<Circle> circles;
  final Function cancelselection;
  final Function addNewAsk;
  final Function addNewExpedient;

  bool isCollapsed = true;
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
    @required this.circles,
    @required this.cancelselection,
    @required this.addNewExpedient, 
    @required this.addNewAsk
  });

  @override
  void initState() {
    super.initState();
    setState(() {
      this.controller = AnimationController(duration: const Duration(milliseconds: 200), vsync:this);
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    screemHeight = size.height;
    screemWidth = size.width;
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Stack(
        children: <Widget>[
          menu(context),
          AnimatedPositioned(
            duration: Duration(milliseconds: 200),
            top: 0,
            bottom: 0,
            left: !isCollapsed ? screemWidth/2 : 0,
            right: !isCollapsed ? -screemWidth/2 : 0,
            child: Material(
              clipBehavior: Clip.antiAlias,
              borderRadius: BorderRadius.all(Radius.circular(40)),
              elevation: 8,
              child: Stack(
                children: <Widget>[
                  GoogleMap(
                    onTap: this.onTap,
                    buildingsEnabled: true,
                    circles: this.circles,
                    mapType: MapType.normal, 
                    onLongPress: this.putMarker,
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
                  Padding(
                    padding: EdgeInsets.only(left: 15, bottom: 15, right: 15),
                    child: AnimatedAlign(
                      duration: Duration(milliseconds: 200),
                      alignment: isCollapsed? Alignment.bottomRight : Alignment.bottomLeft,
                      child: Container(
                        child: FloatingActionButton(
                          backgroundColor: Colors.white,
                          child: AnimatedIcon(
                            size: 30,
                            icon: AnimatedIcons.menu_home,
                            color: Theme.of(context).primaryColor,
                            progress: this.controller
                          ),
                          onPressed: (){
                            setState(() {
                              isCollapsed = !isCollapsed;
                              isCollapsed ? controller.reverse() : controller.forward();
                            });
                          },
                        ),
                        padding: const EdgeInsets.all(1.0)
                      )
                    ),
                  )
                ]
              )
            ) 
          )
        ],
      ),
    );
  }

  String getName(){
    int end = ' '.allMatches(this.name).length >= 1 ? 2: 1;
    return this.name.split(' ').sublist(0, end).join(' ');
  }

  String getEmail(){
    return this.email.length > 27 ? this.email.substring(0,24)+"..." : this.email;
  }
  
  Widget menu(context){
    return Padding(
      padding: const EdgeInsets.only(left: 6.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.transparent,
              backgroundImage: NetworkImage(this.photoUrl)
            ),
            SizedBox(height: 5),
            Text(this.getName(), style: TextStyle(color: Colors.white, fontSize: 22)),
            SizedBox(height: 5),
            Text(this.getEmail(), style: TextStyle(color: Colors.white, fontSize: 11)),
            SizedBox(height: 20),
            SideMenuButton(
              text: "Novo Pedido",
              onPressed: this.addNewAsk,
              icon: Icons.scatter_plot,
            ),
            SideMenuButton(
              text: "Novo Expediente",
              onPressed: this.addNewExpedient,
              icon: Icons.work,
            ),
            SideMenuButton(
              text: "Histórico",
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => StoreConnector<StoreState, Firestore>(
                      converter: (store) => store.state.firestore,
                      builder:  (context, firestore) => HistoryPage(email: this.email, firestore: firestore)
                    )
                  )
                );
              },
              icon: Icons.timeline,
            ),
            SideMenuButton(
              text: "Ajuda",
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => HelpPage()
                  )
                );
              },
              icon: Icons.help_outline,
            ),
            SideMenuButton(
              text: "Deslogar",
              onPressed: this.logout,
              icon: Icons.exit_to_app,
            )
          ]
        )
      ),
    );
  }
}
