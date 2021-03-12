import 'dart:convert';
import 'package:perna/models/user.dart';

class SignInResponse {
  SignInResponse({this.message, this.user, this.error});

  factory SignInResponse.fromJson(Map<String, dynamic> parsedJson) {
    const JsonDecoder decoder = JsonDecoder();
    return SignInResponse(
        message: parsedJson['message'] as String,
        user: User.fromJson(decoder.convert(parsedJson['user'] as String)
            as Map<String, dynamic>),
        error: parsedJson['error'] as String);
  }

  String? message;
  User? user;
  String? error;

  SignInResponse copyWith({String? message, User? user, String? error}) =>
      SignInResponse(
          message: message ?? this.message,
          user: user ?? this.user,
          error: error ?? this.error);

  dynamic toJson() => <String, dynamic>{
        'message': message,
        'user': user?.toJson(),
        'error': error
      };
}
