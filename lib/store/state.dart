import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:perna/models/user.dart';

// utilizar o que foi aprendido sobre polylines para mostrar as rotas que seram feitas pelos motoristas (mostrar sempre a rota mais próxima que ainda não terminou)

class StoreState{
  bool logedIn;
  User user;
  Firestore firestore;

  StoreState({
    this.logedIn,
    this.user,
    this.firestore
  });

  static StoreState fromJson(dynamic json) {
    return StoreState(
      user: json != null ? User.fromJson(json["user"]): null,
      logedIn: json != null ? json["logedIn"] : false
    );
  }

  StoreState copyWith({user, logedIn, firestore}) => StoreState(
    user: user ?? this.user,
    logedIn: logedIn ?? this.logedIn,
    firestore: firestore ?? this.firestore
  );

  dynamic toJson(){
    return {
      "user": user.toJson(),
      "logedIn": logedIn
    };
  }
}