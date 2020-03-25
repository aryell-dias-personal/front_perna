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
  // utilizar o valor retornado pela api com os usuários no state, 
  // colocar o flutter_redux_persist pra tirar o sign_silently da hora de entrar no app
  // utilizar o que foi aprendido sobre polylines para mostrar as rotas que seram feitas pelos motoristas (mostrar sempre a rota mais próxima que ainda não terminou)

  StoreState({
    this.currentUser, 
    this.locationData, 
    this.location, 
    this.driverMarkers, 
    this.userMarkers,
    this.logedIn
  });
}