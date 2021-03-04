class User {
  String email;
  String photoUrl;
  String name;
  String token;
  String currency;
  bool isProvider;

  User({this.email, this.photoUrl, this.name, this.isProvider, this.token, this.currency});

  factory User.fromJson(Map<String, dynamic> parsedJson){
    return User(
      email: parsedJson['email'],
      photoUrl: parsedJson['photoUrl'],
      name: parsedJson['name'],
      isProvider: parsedJson['isProvider'],
      currency: parsedJson['currency'],
      token: null
    );
  }
  
  User copyWith({message, user, error, token, currency}) => User(
    email: email ?? this.email, 
    photoUrl: photoUrl ?? this.photoUrl, 
    name: name ?? this.name,
    isProvider: isProvider ?? this.isProvider,
    currency: currency ?? this.currency,
    token: token ?? this.token
  );

  dynamic toJson() => {
    "email": email,
    "photoUrl": photoUrl,
    "name": name,
    "isProvider": isProvider,
    "currency": currency,
    "token": null
  };
}