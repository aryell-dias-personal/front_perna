import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:perna/models/user.dart';
import 'package:perna/services/driver.dart';
import 'package:perna/services/signIn.dart';
import 'package:perna/services/user.dart';

class StoreState{
  bool logedIn;
  User user;
  String messagingToken;
  Firestore firestore;
  UserService userService;
  DriverService driverService;
  SignInService signInService;

  StoreState({
    this.logedIn,
    this.user,
    this.firestore,
    this.messagingToken,
    this.userService,
    this.driverService,
    this.signInService
  });

  static StoreState fromJson(dynamic json) {
    return StoreState(
      user: json != null ? User.fromJson(json["user"]): null,
      logedIn: json != null ? json["logedIn"] : false
    );
  }

  StoreState copyWith({user, logedIn, firestore, messagingToken, userService, driverService, signInService}) => StoreState(
    user: user ?? this.user,
    logedIn: logedIn ?? this.logedIn,
    firestore: firestore ?? this.firestore,
    messagingToken: messagingToken ?? this.messagingToken,
    userService: userService ?? this.userService,
    driverService: driverService ?? this.driverService,
    signInService: signInService ?? this.signInService
  );

  dynamic toJson(){
    return {
      "user": user.toJson(),
      "logedIn": logedIn
    };
  }
}