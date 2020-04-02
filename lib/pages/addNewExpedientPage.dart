import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:perna/widgets/expedientWidget.dart';

class AddNewExpedientPage extends StatelessWidget {
  final Set<Marker> driverMarkers;

  const AddNewExpedientPage({Key key, @required this.driverMarkers}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Stack(
        children: <Widget>[
          ExpedientWidget(driverMarkers: driverMarkers)
        ] 
      )
    );
  }
}