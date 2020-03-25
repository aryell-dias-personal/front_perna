import 'package:google_map_polyline/google_map_polyline.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:perna/constants/constants.dart';
import 'package:perna/store/actions.dart';
import 'package:perna/store/state.dart';
import 'package:perna/store/stores.dart';
import 'package:perna/widgets/driverWidget.dart';
import 'package:perna/widgets/mapsHeader.dart';
import 'package:perna/widgets/userWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:location/location.dart';
import 'dart:async';

class MainPage extends StatelessWidget {
  final Function onLogout;

  MainPage({@required this.onLogout});
  @override
  Widget build(BuildContext context) {
    return MainPageWidget(onLogout: onLogout);
  }
}

class MainPageWidget extends StatefulWidget {
  final Function onLogout;

  MainPageWidget({@required this.onLogout, Key key}) : super(key: key);

  @override
  _MainPageWidgetState createState() => _MainPageWidgetState(onLogout: this.onLogout);
}

class _MainPageWidgetState extends State<MainPageWidget> {
  
  final Set<Polyline> polyline = Set();
  List<LatLng> routeCooords = [];
  GoogleMapPolyline googleMapPolyline = new GoogleMapPolyline(apiKey: "AIzaSyA0c4Mw7rRAiJxiTQwu6eJcoroBeWWa06w");

  Completer<GoogleMapController> mapsController = Completer();
  int currentIndex = 0;
  final Function onLogout;

  _MainPageWidgetState({@required this.onLogout});

  @override
  void initState() {
    super.initState();
    Location location = Location();
    googleMapPolyline.getCoordinatesWithLocation(
        origin: LatLng(40.677939, -73.941755),
        destination: LatLng(40.698432, -73.924038),
        mode:  RouteMode.driving).then((polylines) async {
          await googleMapPolyline.getCoordinatesWithLocation(
            destination: LatLng(40.677939, -73.941755),
            origin: LatLng(40.698432, -73.924038),
            mode:  RouteMode.driving).then((polylines2){
              this.routeCooords.addAll(polylines2);
              this.routeCooords.addAll(polylines);
            });
        });	
    requestLocation(location).then((enabled) async {
      if (enabled) {
        centralize(await location.getLocation());
        location.onLocationChanged().listen((LocationData currentLocation) {
          store.dispatch(UpdateLocation(currentLocation));
        });
      }
    });
  }

  void onMapCreated(GoogleMapController googleMapController) async {
    setState(() {
      this.mapsController.complete(googleMapController);
      polyline.add(Polyline(
        polylineId: PolylineId('rota1'),
        visible: true,
        points: routeCooords,
        width: 4,
        color: Colors.blueAccent,
        startCap: Cap.roundCap,
        endCap: Cap.buttCap
      ));
    });
  }

  void centralize(LocationData locationData) async {
    final GoogleMapController controller = await this.mapsController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      // target: LatLng(locationData.latitude, locationData.longitude),
      target: LatLng(40.677939, -73.941755),
      zoom: 17.8,
    )));
  }
 
  void _onTapNavigation(selectedIndex) {
    setState(() {
      this.currentIndex = selectedIndex;
    });
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

  void onSelected(MenuOption option, Function logoutFunction, List<Set<Marker>> markers) {
    if (MenuOption.logout == option) {
      logoutFunction();
    } else if (MenuOption.clear == option) {
      markers[this.currentIndex].clear();
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

  @override
  Widget build(BuildContext context) {
    return StoreConnector<StoreState, Map<String, dynamic>>(
      converter: (store) {
        return {
          'markers': [store.state.driverMarkers, store.state.userMarkers],
          'target': LatLng(0, 0),
          'logoutFunction': () {
            this.onLogout();
            store.dispatch(Logout());
          },
          'onLongPress': [
            (location) => store.dispatch(PutDriverMarker(location)),
            (location) => store.dispatch(PutUserMarker(location))
          ],
          'locationData':store.state.locationData,
          'photoUrl':store.state.currentUser?.photoUrl
        };
      },
      builder: (context, resources) {
        return Scaffold(
          body: Stack(
            children: <Widget>[
              GoogleMap(
                mapType: MapType.normal,
                onLongPress: resources['onLongPress'][this.currentIndex],
                polylines: polyline,
                markers: resources['markers'][this.currentIndex],
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                initialCameraPosition: CameraPosition(
                  target: resources['target'],
                  zoom: 17.8,
                ),
                onMapCreated: onMapCreated,
              ),
              MapsHeader(
                onSelected: (option)=>onSelected(option, resources['logoutFunction'], resources['markers']), 
                menuBuilder: menuBuilder,
                photoUrl: resources['photoUrl']
              ),
              [DriverWidget(), UserWidget()][this.currentIndex]
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.directions_bus),
                title: Text('Motorista'),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.people),
                title: Text('Passageiro'),
              )
            ],
            elevation: 8,
            backgroundColor: Colors.white,
            currentIndex: this.currentIndex,
            selectedItemColor: Theme.of(context).primaryColor,
            onTap: _onTapNavigation
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => centralize(resources['locationData']),
            child: Icon(Icons.gps_fixed),
            backgroundColor: Theme.of(context).primaryColor,
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked
        );
      }
    );
  }

}
