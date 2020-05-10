import 'dart:convert';

import 'package:perna/models/user.dart';

class SignInResponse{
  String message;
  User user;
  String error;

  SignInResponse({this.message, this.user, this.error});

  factory SignInResponse.fromJson(Map<String, dynamic> parsedJson){
    JsonDecoder decoder =  JsonDecoder();
    return SignInResponse(
      message: parsedJson['message'], 
      user: User.fromJson(decoder.convert(parsedJson['user'])), 
      error: parsedJson['error']
    );
  }

  SignInResponse copyWith({message, user, error}) => SignInResponse(
    message: message ?? this.message, 
    user: user ?? this.user, 
    error: error ?? this.error
  );

  dynamic toJson() => {
    "message": message,
    "user": user.toJson(),
    "error": error
  };
}