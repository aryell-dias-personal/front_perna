import 'package:perna/models/user.dart';

class StoreState{
  StoreState({
    this.logedIn,
    this.user,
    this.messagingToken
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

  StoreState copyWith({
    User user, 
    bool logedIn, 
    String messagingToken, 
  }) => StoreState(
    user: user ?? this.user,
    logedIn: logedIn ?? this.logedIn,
    messagingToken: messagingToken ?? this.messagingToken,
  );

  dynamic toJson(){
    return <String, dynamic>{
      'user': user.toJson(),
      'logedIn': logedIn
    };
  }
}