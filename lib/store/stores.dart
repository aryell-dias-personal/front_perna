import 'package:perna/store/reducers.dart';
import 'package:perna/store/state.dart';
import 'package:redux/redux.dart';

final store = new Store<StoreState>(
  reduce, initialState: StoreState(logedIn: false)
);