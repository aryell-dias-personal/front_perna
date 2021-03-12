import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:app_settings/app_settings.dart';
import 'package:perna/helpers/app_localizations.dart';

class NoConnectionPage extends StatelessWidget {
  const NoConnectionPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AvatarGlow(
              endRadius: 90,
              glowColor: Colors.grey,
              repeatPauseDuration: const Duration(seconds: 2),
              startDelay: const Duration(seconds: 1),
              child: Material(
                  elevation: 8.0,
                  shape: const CircleBorder(),
                  child: CircleAvatar(
                    backgroundColor: Theme.of(context).backgroundColor,
                    radius: 50.0,
                    child: Icon(
                      Icons.signal_wifi_off,
                      size: 60,
                      color: Theme.of(context).primaryColor,
                    ),
                  )),
            ),
            Text(
              AppLocalizations.of(context).translate('no_connection'),
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 33.0,
                  color: Theme.of(context).primaryColor),
            ),
            Text(
              AppLocalizations.of(context).translate('ask_to_connect'),
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 33.0,
                  color: Theme.of(context).primaryColor),
            ),
            const SizedBox(
              height: 50.0,
            ),
            ElevatedButton(
              onPressed: () {
                AppSettings.openWIFISettings();
              },
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(Theme.of(context).primaryColor),
                  padding: MaterialStateProperty.all(
                      const EdgeInsets.fromLTRB(20, 10, 20, 10)),
                  shape: MaterialStateProperty.all(const StadiumBorder())),
              child: Text(
                AppLocalizations.of(context).translate('go_to_settings'),
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25.0,
                    color: Theme.of(context).backgroundColor),
              ),
            )
          ],
        )));
  }
}
