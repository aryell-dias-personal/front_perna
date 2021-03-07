import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:perna/models/user.dart';
import 'package:perna/services/driver.dart';
import 'package:perna/services/payments.dart';
import 'package:perna/services/sign_in.dart';
import 'package:perna/services/user.dart';

class StoreState{
  StoreState({
    this.logedIn,
    this.user,
    this.firestore,
    this.messagingToken,
    this.userService,
    this.driverService,
    this.signInService,
    this.paymentsService
  });

  // ignore: prefer_constructors_over_static_methods
  static StoreState fromJson(dynamic parsedJson) {
    if(parsedJson == null){
      return StoreState(
        logedIn: false
      );
    }
    return StoreState(
      user: User.fromJson(parsedJson['user'] as Map<String, dynamic>),
      logedIn: parsedJson['logedIn'] as bool
    );
  }

  bool logedIn;
  User user;
  String messagingToken;
  FirebaseFirestore firestore;
  UserService userService;
  DriverService driverService;
  SignInService signInService;
  PaymentsService paymentsService;

  StoreState copyWith({
    User user, 
    bool logedIn, 
    FirebaseFirestore firestore, 
    String messagingToken, 
    UserService userService, 
    DriverService driverService, 
    SignInService signInService, 
    PaymentsService paymentsService
  }) => StoreState(
    user: user ?? this.user,
    logedIn: logedIn ?? this.logedIn,
    firestore: firestore ?? this.firestore,
    messagingToken: messagingToken ?? this.messagingToken,
    userService: userService ?? this.userService,
    driverService: driverService ?? this.driverService,
    signInService: signInService ?? this.signInService,
    paymentsService: paymentsService ?? this.paymentsService
  );

  dynamic toJson(){
    return <String, dynamic>{
      'user': user.toJson(),
      'logedIn': logedIn
    };
  }
}