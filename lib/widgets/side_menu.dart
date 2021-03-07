import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:perna/helpers/help_helper.dart';
import 'package:perna/helpers/app_localizations.dart';
import 'package:perna/helpers/show_snack_bar.dart';
import 'package:perna/pages/help_page.dart';
import 'package:perna/pages/history_page.dart';
import 'package:perna/pages/wallet_page.dart';
import 'package:perna/widgets/side_menu_button.dart';
import 'package:perna/widgets/visible_rich_text.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({
    this.email, 
    this.name, 
    this.photoUrl, 
    this.logout, 
    this.textColor
  });

  final String email;
  final String name;
  final String photoUrl;
  final Function() logout;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6.0),
      child: Align(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CircleAvatar(
              radius: 50,
              backgroundColor: textColor,
              backgroundImage: NetworkImage(photoUrl),
              child: photoUrl==null || photoUrl == ''? 
                const Icon(Icons.person, size: 90): null,
            ),
            const SizedBox(height: 10),
            VisibleRichText(
              fontSize: 22, 
              text: _getName(), 
              textColor: textColor
            ),
            const SizedBox(height: 5),
            VisibleRichText(
              fontSize: 11, 
              text: _getEmail(), 
              textColor: textColor
            ),
            const SizedBox(height: 20),
            SideMenuButton(
              textColor: textColor,
              text: AppLocalizations.of(context).translate('history'),
              onPressed: (){
                Navigator.push(context, MaterialPageRoute<HistoryPage>(
                    builder: (BuildContext context) => HistoryPage(email: email)
                  )
                );
              },
              icon: Icons.timeline,
            ),
            SideMenuButton(
              textColor: textColor,
              text: AppLocalizations.of(context).translate('wallet'),
              onPressed: () async {
                Navigator.push(context, MaterialPageRoute<WalletPage>(
                    builder: (BuildContext context) => WalletPage()
                  )
                );
              },
              icon: Icons.account_balance_wallet_outlined,
            ),
            SideMenuButton(
              textColor: textColor,
              text: 'Empresa',
              onPressed: () {
                showSnackBar(
                  AppLocalizations.of(context).translate('not_implemented'), 
                  Colors.pinkAccent, context);
              },
              icon: Icons.business,
            ),
            SideMenuButton(
              textColor: textColor,
              text: AppLocalizations.of(context).translate('theme'),
              onPressed: (){
                showSnackBar(
                  AppLocalizations.of(context).translate('not_implemented'), 
                  Colors.pinkAccent, context);
              },
              icon: Icons.palette,
            ),
            SideMenuButton(
              textColor: textColor,
              text: AppLocalizations.of(context).translate('help'),
              onPressed: (){
                Navigator.push(context, MaterialPageRoute<HelpPage>(
                    builder: (BuildContext context) => HelpPage(
                      helpItem: getHelpRoot(context),
                    )
                  )
                );
              },
              icon: Icons.help_outline,
            ),
            SideMenuButton(
              textColor: textColor,
              text: AppLocalizations.of(context).translate('logout'),
              onPressed: logout,
              icon: Icons.exit_to_app,
            )
          ]
        )
      ),
    );
  }

  
  String _getName(){
    final int end = ' '.allMatches(name).isEmpty ? 2: 1;
    return name.split(' ').sublist(0, end).join(' ');
  }

  String _getEmail(){
    return email.length > 27 ? '${email.substring(0,24)}...' : email;
  }
}