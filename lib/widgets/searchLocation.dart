import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/directions.dart';
import 'package:google_maps_webservice/places.dart';

class SearchLocation extends StatefulWidget {
  final Future Function(Location, String) onStartPlaceSelected;
  final Future Function(Location, String) onEndPlaceSelected;
  final Set<Marker> markers;

  const SearchLocation({Key key, @required this.onStartPlaceSelected, @required this.onEndPlaceSelected, @required this.markers}) : super(key: key);

  @override
  _SearchLocationState createState() => _SearchLocationState(onStartPlaceSelected: this.onStartPlaceSelected, onEndPlaceSelected: this.onEndPlaceSelected, markers: this.markers);
}

class _SearchLocationState extends State<SearchLocation> with TickerProviderStateMixin {
  bool showSecond = false;
  final Future Function(Location, String) onStartPlaceSelected;
  final Future Function(Location, String) onEndPlaceSelected;
  final Set<Marker> markers;
  
  TextEditingController initialController = TextEditingController();
  TextEditingController endControler = new TextEditingController();

  GoogleMapsPlaces _places = new GoogleMapsPlaces(apiKey:"AIzaSyB8vF6jy-hpVosJ_LwwczTJTN55TimCEfQ");

  _SearchLocationState({@required this.onStartPlaceSelected, @required this.onEndPlaceSelected, @required this.markers});

  void execute(String hint, int type) async {
    Prediction prediction = await PlacesAutocomplete.show(
      context: context,
      apiKey: "AIzaSyB8vF6jy-hpVosJ_LwwczTJTN55TimCEfQ",
      mode: Mode.overlay,
      hint: hint,
      overlayBorderRadius: BorderRadius.all(Radius.circular(15.0)),
      language: "pt", components: [
        Component(Component.country, "br")
      ]
    );
    PlacesDetailsResponse placesDetailsResponse = await _places.getDetailsByPlaceId(prediction.placeId);
    Location location = placesDetailsResponse.result.geometry.location;
    if(type == 0){
      await onStartPlaceSelected(location, prediction.description);
      this.initialController.text = prediction.description;
    }else{
      await onEndPlaceSelected(location, prediction.description);
      this.endControler.text = prediction.description;
    }

  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      if(this.markers!=null && this.markers.length>0) { 
        this.initialController.text = this.markers.first.infoWindow.snippet;
      } else {
        this.initialController.text = "";
      }
      if(this.markers!=null && this.markers.length>1) {
        this.endControler.text = this.markers.last.infoWindow.snippet;
      } else {
        this.endControler.text = "";
      }
    });
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(left: 15, top: 30, right: 15),
        child: Align(
          alignment: Alignment.topCenter,
          child: Container( 
              child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: initialController,
                  decoration: new InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    suffixIcon: Icon(Icons.pin_drop),
                    contentPadding:
                        EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                    hintText: "Digite o nome do seu local de partida"
                  ),
                  autofocus: false,
                  enableInteractiveSelection: false,
                  readOnly: true,
                  showCursor: false,
                  onTap: () {
                    this.execute("Digite o nome do seu local de partida", 0);
                  }
                ),
                AnimatedSize(
                  vsync: this,
                  curve: Curves.linear,
                  duration: Duration(milliseconds: 200),
                  child: Container(
                    child: showSecond? TextField(
                      controller: endControler,
                      decoration:  new InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        suffixIcon: Icon(Icons.flag),
                        contentPadding:
                            EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                        hintText: "Digite o nome do seu local de destino"
                      ),
                      autofocus: false,
                      enableInteractiveSelection: false,
                      readOnly: true,
                      showCursor: false,
                      onTap: () {
                        this.execute("Digite o nome do seu local de destino", 1);
                      }
                    ): SizedBox()
                  )
                ),
                FlatButton(
                  onPressed: (){
                    setState(() {
                      this.showSecond = !this.showSecond;
                    });
                  },
                  shape: StadiumBorder(),
                  color: Colors.transparent,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(showSecond? "Ocultar destino":"Mostrar destino", style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 18)),
                      SizedBox(width: 2),
                      Icon(showSecond?Icons.remove:Icons.add, color: Theme.of(context).primaryColor, size: 18)
                    ],
                  ),
                )
              ]
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black38,
                  offset: Offset(1.0, 1.0),
                  blurRadius: 3),
              ],
              borderRadius: new BorderRadius.all(
                const Radius.circular(15.0)
              )
            ),
          ),
        ), 
      )
    );
  }
}