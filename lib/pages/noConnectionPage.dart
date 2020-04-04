import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:app_settings/app_settings.dart';

class NoConnectionPage extends StatelessWidget {

  const NoConnectionPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child:Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[ 
            AvatarGlow(
              endRadius: 90,
              duration: Duration(seconds: 2),
              glowColor: Colors.white24,
              repeat: true,
              repeatPauseDuration: Duration(seconds: 2),
              startDelay: Duration(seconds: 1),
              child: Material(
                  elevation: 8.0,
                  shape: CircleBorder(),
                  child: CircleAvatar(
                    backgroundColor: Colors.grey[100],
                    child: Icon(
                      Icons.signal_wifi_off,
                      size: 60,
                      color: Theme.of(context).primaryColor,
                    ),
                    radius: 50.0,
                  )),
            ),
            Text(
              "Você não tá conectado!!!",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 33.0,
                  color: Color(0xFFFFFFFF)),
            ),
            Text(
              "Se conecta ai...  😢",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 33.0,
                  color: Color(0xFFFFFFFF)),
            ),
            SizedBox(
              height: 50.0,
            ),
            RaisedButton(
              child: Text(
                'Ver as configurações',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25.0,
                    color: Theme.of(context).primaryColor),
              ),
              onPressed: (){AppSettings.openWIFISettings();},
              color: Colors.white,
              padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
              shape: StadiumBorder()
            )
          ],
        )
      )
    );
  }
}