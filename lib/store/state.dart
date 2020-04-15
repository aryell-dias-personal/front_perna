import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:perna/models/user.dart';

class StoreState{
  bool logedIn;
  User user;
  String messagingToken;
  Firestore firestore;

  StoreState({
    this.logedIn,
    this.user,
    this.firestore,
    this.messagingToken
  });

  static StoreState fromJson(dynamic json) {
    return StoreState(
      user: json != null ? User.fromJson(json["user"]): null,
      logedIn: json != null ? json["logedIn"] : false
    );
  }

  StoreState copyWith({user, logedIn, firestore, messagingToken}) => StoreState(
    user: user ?? this.user,
    logedIn: logedIn ?? this.logedIn,
    firestore: firestore ?? this.firestore,
    messagingToken: messagingToken ?? this.messagingToken
  );

  dynamic toJson(){
    return {
      "user": user.toJson(),
      "logedIn": logedIn
    };
  }
}