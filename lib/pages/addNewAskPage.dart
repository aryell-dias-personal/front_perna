import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:perna/widgets/askWidget.dart';

class AddNewAskPage extends StatelessWidget {
  final Set<Marker> userMarkers;

  const AddNewAskPage({Key key, @required this.userMarkers}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Stack(
        children: <Widget>[
          AskWidget(userMarkers: userMarkers)
        ] 
      )
    );
  }
}