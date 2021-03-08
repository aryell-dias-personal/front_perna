import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:perna/helpers/app_localizations.dart';
import 'package:perna/helpers/show_snack_bar.dart';
import 'package:perna/models/user.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({Key key, @required this.user}) : super(key: key);

  final User user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              AvatarGlow(
                  endRadius: 90,
                  glowColor: Colors.grey,
                  repeatPauseDuration: const Duration(),
                  startDelay: const Duration(seconds: 1),
                  child: Material(
                    shape: const CircleBorder(),
                    color: Colors.transparent,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: NetworkImage(user.photoUrl),
                      child: user.photoUrl==null || user.photoUrl == ''? const Icon(Icons.person, size: 90): null,
                    )
                )
              ),
              Builder(
                builder: (BuildContext context) {
                  final Color unratedColor = Colors.grey.withOpacity(0.2);
                  return RatingBar(
                    initialRating: 5,
                    minRating: 1,
                    allowHalfRating: true,
                    unratedColor: unratedColor,
                    glow: false,
                    itemSize: 50.0,
                    itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                    ratingWidget: RatingWidget(
                      empty: Icon(Icons.star, color: unratedColor),
                      full: const Icon(Icons.star, color: Colors.amber),
                      half: const Icon(Icons.star_half, color: Colors.amber)
                    ),
                    onRatingUpdate: (double rating) {
                      showSnackBar(
                        AppLocalizations.of(context).translate('not_implemented'), 
                        Colors.pinkAccent, context);
                    },
                  );
                }
              ),
              const SizedBox(height: 26),
              TextFormField(
                readOnly: true,
                initialValue: user.name,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: AppLocalizations.of(context).translate('user_name'),
                  suffixIcon: const Icon(Icons.person)
                )
              ),
              const SizedBox(height: 26),
              TextFormField(
                readOnly: true,
                initialValue: user.email,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: AppLocalizations.of(context).translate('user_email'),
                  suffixIcon: const Icon(Icons.email)
                )
              ),
              const SizedBox(height: 26),
              Builder(
                builder: (BuildContext context)=> ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Theme.of(context).primaryColor),
                    shape: MaterialStateProperty.all(const StadiumBorder()),
                  ),
                  onPressed: (){
                    showSnackBar(
                      AppLocalizations.of(context).translate('not_implemented'), 
                      Colors.pinkAccent, context);
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children:<Widget>[
                      Text(AppLocalizations.of(context).translate('talk'), style: TextStyle(color: Theme.of(context).backgroundColor, fontSize: 18)),
                      const SizedBox(width: 5),
                      Icon(Icons.message, color: Theme.of(context).backgroundColor, size: 20)
                    ]
                  ),
                )
              )
            ],
          )
        )
      )
    );
  }
}