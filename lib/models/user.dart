class User {
  String email;
  String photoUrl;
  String name;
  bool isProvider;
  User({this.email, this.photoUrl, this.name, this.isProvider});

  factory User.fromJson(Map<String, dynamic> parsedJson){
    return User(
      email: parsedJson['email'],
      photoUrl: parsedJson['photoUrl'],
      name: parsedJson['name'],
      isProvider: parsedJson['isProvider']
    );
  }

  dynamic toJson() => {
    "email": email,
    "photoUrl": photoUrl,
    "name": name,
    "isProvider": isProvider
  };
}