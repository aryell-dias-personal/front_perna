import 'package:perna/models/user.dart';

// utilizar o que foi aprendido sobre polylines para mostrar as rotas que seram feitas pelos motoristas (mostrar sempre a rota mais próxima que ainda não terminou)

class StoreState{
  bool logedIn;
  User user;

  StoreState({
    this.logedIn,
    this.user
  });

  static StoreState fromJson(dynamic json) {
    return StoreState(
      user: json != null ? User.fromJson(json["user"]): null,
      logedIn: json != null ? json["logedIn"] : false
    );
  }

  StoreState copyWith({user, logedIn}) => StoreState(
    user: user ?? this.user,
    logedIn: logedIn ?? this.logedIn
  );

  dynamic toJson(){
    return {
      "user": user.toJson(),
      "logedIn": logedIn
    };
  }
}