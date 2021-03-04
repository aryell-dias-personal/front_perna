import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';
import 'package:perna/helpers/myDecoder.dart';
import 'package:perna/models/signInResponse.dart';
import 'package:perna/models/user.dart';

class SignInService {
  GoogleSignIn googleSignIn;
  FirebaseAuth firebaseAuth;
  MyDecoder myDecoder;
  String baseUrl = FlavorConfig.instance.variables['baseUrl'];

  SignInService({
    this.googleSignIn, 
    this.firebaseAuth,
    this.myDecoder,
  });

  Future<IdTokenResult> getRefreshToken() async {
    FirebaseUser firebaseUser = await firebaseAuth.currentUser();
    IdTokenResult idTokenResult = await firebaseUser.getIdToken(refresh: true);
    return idTokenResult;
  }

  Future<SignInResponse> logOut({dynamic user, String messagingToken}) async {
    await this.googleSignIn.signOut();
    if(user!=null){
      await _logoutService(user, messagingToken);
    }
    return null;
  }

  Future<SignInResponse> logIn(String messagingToken) async {
    GoogleSignInAccount user = await this.googleSignIn.signIn();
    if(user != null){
      SignInResponse signInResponse = await this._getUser(user, messagingToken);
      if (signInResponse != null){ 
        await _authFirebase(user);
        return signInResponse;
      }
    }
    return await this.logOut();
  }

  Future<SignInResponse> signIn(String messagingToken, String currency) async {
    GoogleSignInAccount user = await this.googleSignIn.signIn();
    if(user != null){
      SignInResponse signInResponse = await this._creatUser(user, messagingToken, true, currency);
      if (signInResponse != null){
        await _authFirebase(user);
        return signInResponse;
      }
    }
    return await this.logOut();
  }

  Future<SignInResponse> _creatUser(GoogleSignInAccount user, String messagingToken, bool isProvider, String currency) async {
    final body = await myDecoder.encode({
      'email': user?.email,
      'isProvider': isProvider,
      'photoUrl': user?.photoUrl,
      'name': user?.displayName,
      'currency': currency,
      'messagingTokens': [ messagingToken ]
    });
    Response res = await post("${baseUrl}insertUser", body: body);
    return res.statusCode == 200 ? SignInResponse.fromJson(await myDecoder.decode(res.body)) : null;
  }

  Future<SignInResponse> _getUser(GoogleSignInAccount user, String messagingToken) async {
    final body = await myDecoder.encode({
      'email': user?.email,
      'messagingToken': messagingToken
    });
    Response res = await post("${baseUrl}getUser", body: body);
    return res.statusCode == 200 ? SignInResponse.fromJson(await myDecoder.decode(res.body)) : null;
  }

  Future<SignInResponse> _logoutService(User user, String messagingToken) async {
    final body = await myDecoder.encode({
      'email': user?.email,
      'messagingToken': messagingToken
    });
    Response res = await post("${baseUrl}logout", body: body);
    return res.statusCode == 200 ? SignInResponse.fromJson(await myDecoder.decode(res.body)) : null;
  }

  Future _authFirebase(GoogleSignInAccount user) async {
    GoogleSignInAuthentication googleAuth = await user.authentication;
    AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    await firebaseAuth.signInWithCredential(credential);
  }
}
