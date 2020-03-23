import 'dart:convert';
import 'package:perna/constants/constants.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';

class SignInService {
  GoogleSignIn googleSignIn;
  SignInService({this.googleSignIn});

  dynamic silentLogin() async{
    GoogleSignInAccount user = await this.googleSignIn.signInSilently();
    if (user != null) {
      return this.assertLogin(user);
    }
    return null;
  }

  dynamic updateStateLogSignIn(int statusCode, GoogleSignInAccount user) async {
    if (statusCode != 200) {
      return await this.logOut();
    }
    return user;
  }

  dynamic logOut() async {
    await this.googleSignIn.signOut();
    return null;
  }

  dynamic assertLogin(GoogleSignInAccount user) async {
    int statusCode = await this.getUser(user?.email);
    return await updateStateLogSignIn(statusCode, user);
  }

  dynamic logIn() async {
    GoogleSignInAccount user = await this.googleSignIn.signIn();
    return await this.assertLogin(user);
  }

  dynamic signIn() async {
    GoogleSignInAccount user = await this.googleSignIn.signIn();
    int statusCode = await this.creatUser(user?.email, true);
    return await this.updateStateLogSignIn(statusCode, user);
  }

  Future<dynamic> creatUser(String email, bool isProvider) async {
    final encoder = JsonEncoder();
    final body = encoder.convert({
      'email': email,
      'isProvider': isProvider,
      'askedPoints': [],
      'agents': []
    });
    Response res = await post("${baseUrl}insertUser", body: body);
    return res.statusCode;
  }

  Future<dynamic> getUser(String email) async {
    final encoder = JsonEncoder();
    final body = encoder.convert({'email': email});
    Response res = await post("${baseUrl}getUser", body: body);
    return res.statusCode;
  }
}
