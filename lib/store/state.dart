import 'package:perna/models/user.dart';

// utilizar o valor retornado pela api com os usuários no state, 
// colocar o flutter_redux_persist pra tirar o sign_silently da hora de entrar no app
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
      user: json != null ? User.fromJson(json["user"]): User(),
      logedIn: json != null ? json["logedIn"] : false
    );
  }

  dynamic toJson() => {
    "user": user.toJson(),
    "logedIn": logedIn
  };
}