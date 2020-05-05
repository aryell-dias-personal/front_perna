import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MyGoogleMap extends StatelessWidget {
  final Function() preExecute;
  final Function(LatLng) onTap;
  final Function(LatLng) onLongPress;
  final Set<Polyline> polyline;
  final Set<Marker> markers;
  final Function(GoogleMapController) onMapCreated;

  const MyGoogleMap({Key key, this.preExecute, this.onLongPress, this.onTap, this.onMapCreated, this.polyline, this.markers}) : super(key: key); 

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      onTap: this.onTap,
      buildingsEnabled: true,
      mapType: MapType.normal, 
      onLongPress: (location){
        this.preExecute();
        this.onLongPress(location);
      },
      onCameraMove: (location){
        this.preExecute();
      },
      polylines: this.polyline,
      markers: this.markers,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      initialCameraPosition: CameraPosition(
        target: LatLng(-8.05428, -34.8813),
        zoom: 20,
      ),
      onMapCreated: this.onMapCreated,
    );
  }
}