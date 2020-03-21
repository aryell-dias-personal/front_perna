import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:location/location.dart';

class StoreState{

  Set<Marker> driverMarkers = Set();
  Set<Marker> userMarkers = Set();
  LocationData locationData;
  Location location;
  GoogleSignInAccount currentUser;
  bool logedIn;

  StoreState({
    this.currentUser, 
    this.locationData, 
    this.location, 
    this.driverMarkers, 
    this.userMarkers,
    this.logedIn
  });
}