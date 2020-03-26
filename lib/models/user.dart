class User {
  String email;
  String photoUrl;
  String name;
  bool isProvider;
  List<dynamic> askedPoints;
  List<dynamic> agents;

  User({this.email, this.photoUrl, this.name, this.isProvider, this.askedPoints, this.agents});

  factory User.fromJson(Map<String, dynamic> parsedJson){
    return User(
      email: parsedJson['email'],
      photoUrl: parsedJson['photoUrl'],
      name: parsedJson['name'],
      isProvider: parsedJson['isProvider'],
      askedPoints: parsedJson['askedPoints'],
      agents: parsedJson['agents']
    );
  }

  dynamic toJson() => {
    "email": email,
    "photoUrl": photoUrl,
    "name": name,
    "isProvider": isProvider,
    "askedPoints": askedPoints,
    "agents": agents
  };
}