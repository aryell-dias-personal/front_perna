class User {
  User(
      {required this.email,
      required this.photoUrl,
      required this.name,
      required this.isProvider,
      required this.currency,
      this.token});

  factory User.fromJson(Map<String, dynamic> parsedJson) {
    return User(
      email: parsedJson['email'] as String,
      photoUrl: parsedJson['photoUrl'] as String,
      name: parsedJson['name'] as String,
      isProvider: parsedJson['isProvider'] as bool,
      currency: parsedJson['currency'] as String,
    );
  }

  String email;
  String photoUrl;
  String name;
  String? token;
  String currency;
  bool isProvider;

  User copyWith(
          {String? email,
          String? photoUrl,
          String? name,
          String? token,
          String? currency,
          bool? isProvider}) =>
      User(
          email: email ?? this.email,
          photoUrl: photoUrl ?? this.photoUrl,
          name: name ?? this.name,
          isProvider: isProvider ?? this.isProvider,
          currency: currency ?? this.currency,
          token: token ?? this.token);

  dynamic toJson() => <String, dynamic>{
        'email': email,
        'photoUrl': photoUrl,
        'name': name,
        'isProvider': isProvider,
        'currency': currency
      };
}
