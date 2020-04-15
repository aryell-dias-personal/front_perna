import 'dart:convert';
import 'package:perna/constants/constants.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';
import 'package:perna/models/signInResponse.dart';
import 'package:perna/models/user.dart';

class SignInService {
  GoogleSignIn googleSignIn;
  SignInService({this.googleSignIn});
  final encoder = JsonEncoder();
  final decoder = JsonDecoder();

  Future<SignInResponse> logOut({dynamic user, String messagingToken}) async {
    await this.googleSignIn.signOut();
    if(user!=null){
      await logoutService(user, messagingToken);
    }
    return null;
  }

  Future<SignInResponse> logIn(String messagingToken) async {
    GoogleSignInAccount user = await this.googleSignIn.signIn();
    if(user != null){
      dynamic userResponse = await this.getUser(user, messagingToken);
      if (userResponse.statusCode == 200)
        return  SignInResponse.fromJson(decoder.convert(userResponse.body));
    }
    return await this.logOut();
  }

  Future<SignInResponse> signIn(String messagingToken) async {
    GoogleSignInAccount user = await this.googleSignIn.signIn();
    if(user != null){
      dynamic userResponse = await this.creatUser(user, messagingToken, true);
      if (userResponse.statusCode == 200)
        return SignInResponse.fromJson(decoder.convert(userResponse.body));
    }
    return await this.logOut();
  }

  Future<dynamic> creatUser(GoogleSignInAccount user, String messagingToken, bool isProvider) async {
    final body = encoder.convert({
      'email': user?.email,
      'isProvider': isProvider,
      'photoUrl': user?.photoUrl,
      'name': user?.displayName,
      'messagingTokens': [ messagingToken ]
    });
    return await post("${baseUrl}insertUser", body: body);
  }

  Future<dynamic> getUser(GoogleSignInAccount user, String messagingToken) async {
    final body = encoder.convert({
      'email': user?.email,
      'messagingToken': messagingToken
    });
    return await post("${baseUrl}getUser", body: body);
  }

  Future<dynamic> logoutService(User user, String messagingToken) async {
    final body = encoder.convert({
      'email': user?.email,
      'messagingToken': messagingToken
    });
    return await post("${baseUrl}logout", body: body);
  }
}
