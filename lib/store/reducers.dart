import 'package:perna/models/user.dart';
import 'package:perna/store/actions.dart';
import 'package:perna/store/state.dart';

StoreState reduce(StoreState state, dynamic action){
  if (action is Logout) {
    return state.copyWith(
      logedIn: false,
      user: User()
    );
  } else if(action is LogIn || action is SignIn){
    if (action?.user != null) {
      return state.copyWith(
        logedIn: true,
        user: action.user
      );
    } 
  }
  return state;
}