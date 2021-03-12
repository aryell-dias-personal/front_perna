import 'package:perna/store/actions.dart';
import 'package:perna/store/state.dart';

StoreState reduce(StoreState state, dynamic action) {
  if (action is Logout) {
    return state.copyWith(logedIn: false);
  } else if (action is LogIn) {
    return state.copyWith(logedIn: true, user: action.user);
  } else if (action is SignIn) {
    return state.copyWith(logedIn: true, user: action.user);
  }
  return state;
}
