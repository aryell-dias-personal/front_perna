import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';
import 'package:perna/helpers/my_decoder.dart';
import 'package:perna/models/sign_in_response.dart';
import 'package:perna/models/user.dart' as model;

class SignInService {
  SignInService({
    this.googleSignIn, 
    this.firebaseAuth,
    this.myDecoder,
  });

  GoogleSignIn googleSignIn;
  FirebaseAuth firebaseAuth;
  MyDecoder myDecoder;
  String baseUrl = FlavorConfig.instance.variables['baseUrl'] as String;

  Future<String> getRefreshToken() async {
    final User firebaseUser = firebaseAuth.currentUser;
    final String token = await firebaseUser.getIdToken();
    return token;
  }

  Future<SignInResponse> logOut({model.User user, String messagingToken}) async {
    await googleSignIn.signOut();
    if(user!=null){
      await _logoutService(user, messagingToken);
    }
    return null;
  }

  Future<SignInResponse> logIn(String messagingToken) async {
    final GoogleSignInAccount user = await googleSignIn.signIn();
    if(user != null){
      final SignInResponse signInResponse = await _getUser(user, messagingToken);
      if (signInResponse != null){ 
        await _authFirebase(user);
        return signInResponse;
      }
    }
    return logOut();
  }

  Future<SignInResponse> signIn(String messagingToken, String currency) async {
    final GoogleSignInAccount user = await googleSignIn.signIn();
    if(user != null){
      final SignInResponse signInResponse = await _creatUser(user, messagingToken, true, currency);
      if (signInResponse != null){
        await _authFirebase(user);
        return signInResponse;
      }
    }
    return logOut();
  }

  Future<SignInResponse> _creatUser(GoogleSignInAccount user, String messagingToken, bool isProvider, String currency) async {
    final String body = await myDecoder.encode(<String, dynamic>{
      'email': user?.email,
      'isProvider': isProvider,
      'photoUrl': user?.photoUrl,
      'name': user?.displayName,
      'currency': currency,
      'messagingTokens': messagingToken != null ? <String>[ messagingToken ] : <String>[]
    });
    final Response res = await post(Uri.parse('${baseUrl}insertUser'), body: body);
    final dynamic jsonResBody = await myDecoder.decode(res.body);
    return res.statusCode == 200 ? SignInResponse.fromJson(jsonResBody as Map<String, dynamic>) : null;
  }

  Future<SignInResponse> _getUser(GoogleSignInAccount user, String messagingToken) async {
    final String body = await myDecoder.encode(<String, String>{
      'email': user?.email,
      'messagingToken': messagingToken
    });
    final Response res = await post(Uri.parse('${baseUrl}getUser'), body: body);
    final dynamic jsonResBody = await myDecoder.decode(res.body);
    return res.statusCode == 200 ? SignInResponse.fromJson(jsonResBody as Map<String, dynamic>) : null;
  }

  Future<SignInResponse> _logoutService(model.User user, String messagingToken) async {
    final String body = await myDecoder.encode(<String, String>{
      'email': user?.email,
      'messagingToken': messagingToken
    });
    final Response res = await post(Uri.parse('${baseUrl}logout'), body: body);
    final dynamic jsonResBody = await myDecoder.decode(res.body);
    return res.statusCode == 200 ? SignInResponse.fromJson(jsonResBody as Map<String, dynamic>) : null;
  }

  Future<void> _authFirebase(GoogleSignInAccount user) async {
    final GoogleSignInAuthentication googleAuth = await user.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    await firebaseAuth.signInWithCredential(credential);
  }
}
