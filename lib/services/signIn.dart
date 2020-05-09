import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:perna/constants/constants.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';
import 'package:perna/models/signInResponse.dart';
import 'package:perna/models/user.dart';

class SignInService {
  GoogleSignIn googleSignIn;
  FirebaseAuth firebaseAuth;
  SignInService({this.googleSignIn, this.firebaseAuth});
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
      SignInResponse signInResponse = await this.getUser(user, messagingToken);
      if (signInResponse != null){
        GoogleSignInAuthentication googleAuth = await user.authentication;
        AuthCredential credential = GoogleAuthProvider.getCredential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await firebaseAuth.signInWithCredential(credential);
        return signInResponse;
      }
    }
    return await this.logOut();
  }

  Future<SignInResponse> signIn(String messagingToken) async {
    GoogleSignInAccount user = await this.googleSignIn.signIn();
    if(user != null){
      SignInResponse signInResponse = await this.creatUser(user, messagingToken, true);
      if (signInResponse != null)
        return signInResponse;
    }
    return await this.logOut();
  }

  Future<SignInResponse> creatUser(GoogleSignInAccount user, String messagingToken, bool isProvider) async {
    final body = encoder.convert({
      'email': user?.email,
      'isProvider': isProvider,
      'photoUrl': user?.photoUrl,
      'name': user?.displayName,
      'messagingTokens': [ messagingToken ]
    });
    Response res = await post("${baseUrl}insertUser", body: body);
    return res.statusCode == 200 ? SignInResponse.fromJson(json.decode(res.body)) : null;
  }

  Future<SignInResponse> getUser(GoogleSignInAccount user, String messagingToken) async {
    final body = encoder.convert({
      'email': user?.email,
      'messagingToken': messagingToken
    });
    Response res = await post("${baseUrl}getUser", body: body);
    return res.statusCode == 200 ? SignInResponse.fromJson(json.decode(res.body)) : null;
  }

  Future<SignInResponse> logoutService(User user, String messagingToken) async {
    final body = encoder.convert({
      'email': user?.email,
      'messagingToken': messagingToken
    });
    Response res = await post("${baseUrl}logout", body: body);
    return res.statusCode == 200 ? SignInResponse.fromJson(json.decode(res.body)) : null;
  }
}
