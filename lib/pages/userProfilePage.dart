import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:perna/helpers/appLocalizations.dart';
import 'package:perna/helpers/showSnackBar.dart';
import 'package:perna/models/user.dart';

class UserProfilePage extends StatelessWidget {
  final User user;

  const UserProfilePage({Key key, @required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Center(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              AvatarGlow(
                  endRadius: 90,
                  duration: Duration(seconds: 2),
                  glowColor: Colors.grey,
                  repeat: true,
                  repeatPauseDuration: Duration(seconds: 0),
                  startDelay: Duration(seconds: 1),
                  child: Material(
                    elevation: 0.0,
                    shape: CircleBorder(),
                    color: Colors.transparent,
                    child: CircleAvatar(
                      radius: 60,
                      // backgroundColor: this.textColor,
                      child: this.user.photoUrl==null || this.user.photoUrl == ""? Icon(Icons.person, size: 90): null,
                      backgroundImage: NetworkImage(this.user.photoUrl)
                    )
                )
              ),
              Builder(
                builder: (context) => RatingBar(
                  initialRating: 5,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  unratedColor: Theme.of(context).brightness == Brightness.light? 
                    Colors.grey.withOpacity(0.2): 
                    Theme.of(context).backgroundColor.withOpacity(0.8),
                  glow: false,
                  itemCount: 5,
                  itemSize: 50.0,
                  itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {
                    showSnackBar(
                      AppLocalizations.of(context).translate("not_implemented"), 
                      Colors.pinkAccent, context: context);
                  },
                ),
              ),
              SizedBox(height: 26),
              TextFormField(
                readOnly: true,
                initialValue: user.name,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: AppLocalizations.of(context).translate("user_name"),
                  suffixIcon: Icon(Icons.person)
                )
              ),
              SizedBox(height: 26),
              TextFormField(
                readOnly: true,
                initialValue: user.email,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: AppLocalizations.of(context).translate("user_email"),
                  suffixIcon: Icon(Icons.email)
                )
              ),
              SizedBox(height: 26),
              Builder(
                builder: (context)=> RaisedButton(
                  onPressed: (){
                    showSnackBar(
                      AppLocalizations.of(context).translate("not_implemented"), 
                      Colors.pinkAccent, context: context);
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children:<Widget>[
                      Text(AppLocalizations.of(context).translate("talk"), style: TextStyle(color: Theme.of(context).backgroundColor, fontSize: 18)),
                      SizedBox(width: 5),
                      Icon(Icons.message, color: Theme.of(context).backgroundColor, size: 20)
                    ]
                  ),
                  color: Theme.of(context).primaryColor,
                  shape: StadiumBorder(),
                )
              )
            ],
          )
        )
      )
    );
  }
}