import 'dart:convert';
import 'package:perna/constants/constants.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';
import 'package:perna/models/signInResponse.dart';

class SignInService {
  GoogleSignIn googleSignIn;
  SignInService({this.googleSignIn});
  final encoder = JsonEncoder();
  final decoder = JsonDecoder();

  Future<SignInResponse> logOut() async {
    await this.googleSignIn.signOut();
    return null;
  }

  Future<SignInResponse> logIn() async {
    GoogleSignInAccount user = await this.googleSignIn.signIn();
    dynamic userResponse = await this.getUser(user);
    if (userResponse.statusCode != 200)
      return await this.logOut();
    return  SignInResponse.fromJson(decoder.convert(userResponse.body));
  }

  Future<SignInResponse> signIn() async {
    GoogleSignInAccount user = await this.googleSignIn.signIn();
    dynamic userResponse = await this.creatUser(user, true);
    if (userResponse.statusCode != 200)
      return await this.logOut();
    return SignInResponse.fromJson(decoder.convert(userResponse.body));
  }

  Future<dynamic> creatUser(GoogleSignInAccount user, bool isProvider) async {
    final body = encoder.convert({
      'email': user?.email,
      'isProvider': isProvider,
      'photoUrl': user?.photoUrl,
      'name': user?.displayName,
      'askedPoints': [],
      'agents': []
    });
    return await post("${baseUrl}insertUser", body: body);
  }

  Future<dynamic> getUser(GoogleSignInAccount user) async {
    final body = encoder.convert({'email': user?.email});
    return await post("${baseUrl}getUser", body: body);
  }
}
