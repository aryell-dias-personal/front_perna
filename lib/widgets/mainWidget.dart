import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:perna/pages/helpPage.dart';
import 'package:perna/pages/historyPage.dart';

class MainWidget extends StatelessWidget {
  final String photoUrl;
  final String name;
  final String email;
  final Function logout;

  final Function onTap;
  final Function putMarker;
  final Function onMapCreated;
  final Set<Polyline> polyline;
  final Set<Marker> markers;
  final Function cancelselection;
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
    @required this.markers,
    @required this.cancelselection,
    @required this.addNewExpedient, 
    @required this.addNewAsk
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return _MainWidget(
      photoUrl: photoUrl, 
      email: this.email, 
      name: this.name, 
      logout: this.logout,
      onTap: this.onTap,
      putMarker: this.putMarker,
      onMapCreated: this.onMapCreated,
      polyline: this.polyline,
      markers: this.markers,
      cancelselection: this.cancelselection,
      addNewExpedient: this.addNewExpedient,
      addNewAsk: this.addNewAsk
    );
  }
}

class _MainWidget extends StatefulWidget {
  final String name;
  final String email;
  final Function logout;
  final String photoUrl;

  final Function onTap;
  final Function putMarker;
  final Function onMapCreated;
  final Set<Polyline> polyline;
  final Set<Marker> markers;
  final Function cancelselection;
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
    @required  this.cancelselection,
    @required this.addNewExpedient, 
    @required this.addNewAsk
  }) : super(key: key);

  @override
  _MainWidgetState createState() => _MainWidgetState(
    photoUrl: photoUrl, 
    email: this.email, 
    name: this.name, 
    logout: this.logout,
    onTap: this.onTap,
    putMarker: this.putMarker,
    onMapCreated: this.onMapCreated,
    polyline: this.polyline,
    markers: this.markers,
    cancelselection: this.cancelselection,
    addNewExpedient: this.addNewExpedient, 
    addNewAsk: this.addNewAsk
  );
}

class _MainWidgetState extends State<_MainWidget> with SingleTickerProviderStateMixin {
  final String name;
  final String email;
  final Function logout;
  final String photoUrl;
  bool isCollapsed = true;
  double screemWidth, screemHeight;
  AnimationController controller;

  final Function onTap;
  final Function putMarker;
  final Function onMapCreated;
  final Set<Polyline> polyline;
  final Set<Marker> markers;
  final Function cancelselection;
  final Function addNewAsk;
  final Function addNewExpedient;

  _MainWidgetState({
    @required this.photoUrl, 
    @required this.name,
    @required this.email, 
    @required this.logout,
    @required this.onTap,
    @required this.putMarker,
    @required this.onMapCreated,
    @required this.polyline,
    @required this.markers,
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
                    mapType: MapType.normal, 
                    onLongPress: this.putMarker,
                    polylines: this.polyline,
                    markers: this.markers,
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
            Text(this.name, style: TextStyle(color: Colors.white, fontSize: 22)),
            SizedBox(height: 5),
            Text(this.email, style: TextStyle(color: Colors.white, fontSize: 11)),
            SizedBox(height: 20),
            FlatButton(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children:<Widget>[
                  Text("Novo Pedido", style: TextStyle(color: Colors.white, fontSize: 18)),
                  SizedBox(width: 2),
                  Icon(Icons.scatter_plot, color: Colors.white, size: 18)
                ]
              ),
              onPressed: this.addNewAsk,
              color: Colors.transparent,
              shape: StadiumBorder(),
            ),
            FlatButton(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children:<Widget>[
                  Text("Novo Expediente", style: TextStyle(color: Colors.white, fontSize: 18)),
                  SizedBox(width: 2),
                  Icon(Icons.work, color: Colors.white, size: 18)
                ]
              ),
              onPressed: this.addNewExpedient,
              color: Colors.transparent,
              shape: StadiumBorder(),
            ),
            FlatButton(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children:<Widget>[
                  Text("Histórico", style: TextStyle(color: Colors.white, fontSize: 18)),
                  SizedBox(width: 2),
                  Icon(Icons.timeline, color: Colors.white, size: 18)
                ]
              ),
              onPressed: (){
                Navigator.push(context, 
                  MaterialPageRoute(
                    builder: (context) => HistoryPage()
                  )
                );
              },
              color: Colors.transparent,
              shape: StadiumBorder(),
            ),
            FlatButton(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children:<Widget>[
                  Text("Ajuda", style: TextStyle(color: Colors.white, fontSize: 18)),
                  SizedBox(width: 2),
                  Icon(Icons.help_outline, color: Colors.white, size: 18)
                ]
              ),
              onPressed: (){
                Navigator.push(context, 
                  MaterialPageRoute(
                    builder: (context) => HelpPage()
                  )
                );
              },
              color: Colors.transparent,
              shape: StadiumBorder(),
            ),
            FlatButton(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children:<Widget>[
                  Text("Deslogar", style: TextStyle(color: Colors.white, fontSize: 18)),
                  SizedBox(width: 2),
                  Icon(Icons.exit_to_app, color: Colors.white, size: 18)
                ]
              ),
              onPressed: this.logout,
              color: Colors.transparent,
              shape: StadiumBorder(),
            )
          ]
        )
      ),
    );
  }
}
