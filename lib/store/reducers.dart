import 'package:perna/store/actions.dart';
import 'package:perna/store/state.dart';

StoreState reduce(StoreState state, dynamic action){
  if (action is Logout) {
    return new StoreState(
      logedIn: false
    );
  } else if ( action is LogIn && action?.user != null) { 
    return new StoreState(
      logedIn: true,
      user: action.user
    );
  } else if ( action is SignIn && action?.user != null) { 
    return new StoreState(
      logedIn: true,
      user: action.user
    );
  }
  return state;
}