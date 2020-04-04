import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:perna/widgets/askWidget.dart';

class AddNewAskPage extends StatelessWidget {
  final Set<Marker> userMarkers;
  final Function clear;

  const AddNewAskPage({Key key, @required this.userMarkers, @required this.clear}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Stack(
        children: <Widget>[
          AskWidget(userMarkers: userMarkers, clear: this.clear)
        ] 
      )
    );
  }
}