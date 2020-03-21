import 'package:google_sign_in/google_sign_in.dart';
import 'package:location/location.dart';

class Logout {}

class LogIn {
  GoogleSignInAccount user;
  LogIn(this.user);
}

class PutDriverMarker {
  dynamic location;
  PutDriverMarker(this.location);
}

class SignIn {
  GoogleSignInAccount user;
  SignIn(this.user);
}

class PutUserMarker {
  dynamic location;
  PutUserMarker(this.location);
}

class UpdateLocation {
  LocationData locationData;
  UpdateLocation(this.locationData);
} 
