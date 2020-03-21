import 'package:perna/store/actions.dart';
import 'package:perna/store/state.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

StoreState reduce(StoreState state, dynamic action){
  if (action is Logout) {
    return new StoreState(
      location: state.location,
      logedIn: false
    );
  } else if ( action is LogIn && action?.user != null) { 
    return new StoreState(
      location: state.location,
      logedIn: true,
      currentUser: action.user
    );
  } else if ( action is SignIn && action?.user != null) { 
    return new StoreState(
      location: state.location,
      logedIn: true,
      currentUser: action.user
    );
  } else if ( action is PutDriverMarker && action?.location != null) { 
    Set<Marker> driverMarkers = state.driverMarkers!=null && state.driverMarkers.length < 1?state.driverMarkers:Set();
    driverMarkers.add(
      Marker(
        markerId: MarkerId(action.location.toString()), 
        position: action.location
      )
    );
    return new StoreState(
      location: state.location,
      logedIn: state.logedIn,
      driverMarkers: driverMarkers,
      userMarkers: state.userMarkers,
      locationData: state.locationData,
      currentUser: state.currentUser
    );
  } else if ( action is PutUserMarker && action?.location != null) { 
    Set<Marker> userMarkers = state.userMarkers!=null && state.userMarkers.length < 2?state.userMarkers:Set();
    userMarkers.add(
      Marker(
        markerId: MarkerId(action.location.toString()), 
        position: action.location
      )
    );
    return new StoreState(
      location: state.location,
      logedIn: state.logedIn,
      driverMarkers: state.driverMarkers,
      userMarkers: userMarkers,
      locationData: state.locationData,
      currentUser: state.currentUser
    );
  } else if ( action is UpdateLocation && action?.locationData != null) { 
    return new StoreState(
      location: state.location,
      logedIn: state.logedIn,
      driverMarkers: state.driverMarkers,
      userMarkers: state.userMarkers,
      locationData: action.locationData,
      currentUser: state.currentUser
    );
  }
  return state;
}