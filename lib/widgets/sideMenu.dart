import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:perna/helpers/helpHelper.dart';
import 'package:perna/helpers/appLocalizations.dart';
import 'package:perna/helpers/showSnackBar.dart';
import 'package:perna/pages/creditCardPage.dart';
import 'package:perna/pages/helpPage.dart';
import 'package:perna/pages/historyPage.dart';
import 'package:perna/store/state.dart';
import 'package:perna/widgets/sideMenuButton.dart';
import 'package:perna/widgets/visibleRichText.dart';

class SideMenu extends StatelessWidget {
  final String email;
  final String name;
  final String photoUrl;
  final Function() logout;
  final Color textColor;

  SideMenu({Key key, this.email, this.name, this.photoUrl, this.logout, this.textColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6.0),
      child: Align(
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CircleAvatar(
              radius: 50,
              backgroundColor: this.textColor,
              child: this.photoUrl==null || this.photoUrl == ""? Icon(Icons.person, size: 90): null,
              backgroundImage: NetworkImage(this.photoUrl)
            ),
            SizedBox(height: 10),
            VisibleRichText(fontSize: 22, text: this._getName(), textColor: this.textColor),
            SizedBox(height: 5),
            VisibleRichText(fontSize: 11, text: this._getEmail(), textColor: this.textColor),
            SizedBox(height: 20),
            SideMenuButton(
              textColor: textColor,
              text: AppLocalizations.of(context).translate("history"),
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => StoreConnector<StoreState, Firestore>(
                      converter: (store) => store.state.firestore,
                      builder:  (context, firestore) => HistoryPage(email: this.email, firestore: firestore)
                    )
                  )
                );
              },
              icon: Icons.timeline,
            ),
            SideMenuButton(
              textColor: textColor,
              text: AppLocalizations.of(context).translate("help"),
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => HelpPage(
                      helpItem: getHelpRoot(context),
                    )
                  )
                );
              },
              icon: Icons.help_outline,
            ),
            SideMenuButton(
              textColor: textColor,
              text: AppLocalizations.of(context).translate("payment"),
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => CreditCardPage()
                  )
                );
              },
              icon: Icons.credit_card,
            ),
            SideMenuButton(
              textColor: textColor,
              text: AppLocalizations.of(context).translate("theme"),
              onPressed: (){
                showSnackBar(
                  AppLocalizations.of(context).translate("not_implemented"), 
                  Colors.pinkAccent, context: context);
              },
              icon: Icons.palette,
            ),
            SideMenuButton(
              textColor: textColor,
              text: AppLocalizations.of(context).translate("logout"),
              onPressed: this.logout,
              icon: Icons.exit_to_app,
            )
          ]
        )
      ),
    );
  }

  
  String _getName(){
    int end = ' '.allMatches(this.name).length >= 1 ? 2: 1;
    return this.name.split(' ').sublist(0, end).join(' ');
  }

  String _getEmail(){
    return this.email.length > 27 ? this.email.substring(0,24)+"..." : this.email;
  }
}