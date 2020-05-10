class User {
  String email;
  String photoUrl;
  String name;
  String token;
  bool isProvider;

  User({this.email, this.photoUrl, this.name, this.isProvider, this.token});

  factory User.fromJson(Map<String, dynamic> parsedJson){
    return User(
      email: parsedJson['email'],
      photoUrl: parsedJson['photoUrl'],
      name: parsedJson['name'],
      isProvider: parsedJson['isProvider'],
      token: null
    );
  }
  
  User copyWith({message, user, error, token}) => User(
    email: email ?? this.email, 
    photoUrl: photoUrl ?? this.photoUrl, 
    name: name ?? this.name,
    isProvider: isProvider ?? this.isProvider,
    token: token ?? this.token
  );

  dynamic toJson() => {
    "email": email,
    "photoUrl": photoUrl,
    "name": name,
    "isProvider": isProvider,
    "token": null
  };
}