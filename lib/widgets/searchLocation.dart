import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/directions.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:perna/constants/constants.dart';

class SearchLocation extends StatefulWidget {
  final Function() preExecute;
  final Future Function(Location, String) onStartPlaceSelected;
  final Future Function(Location, String) onEndPlaceSelected;
  final Set<Marker> markers;

  const SearchLocation({
    Key key, @required this.onStartPlaceSelected, 
    @required this.onEndPlaceSelected, @required this.markers, 
    @required this.preExecute
  }) : super(key: key);

  @override
  _SearchLocationState createState() => _SearchLocationState(
    onStartPlaceSelected: this.onStartPlaceSelected, 
    onEndPlaceSelected: this.onEndPlaceSelected, 
    markers: this.markers, preExecute: this.preExecute
  );
}

class _SearchLocationState extends State<SearchLocation> with TickerProviderStateMixin {
  bool showSecond = false;
  final Function() preExecute;
  final Future Function(Location, String) onStartPlaceSelected;
  final Future Function(Location, String) onEndPlaceSelected;
  final Set<Marker> markers;
  
  TextEditingController initialController = TextEditingController();
  TextEditingController endControler = new TextEditingController();

  GoogleMapsPlaces _places = new GoogleMapsPlaces(apiKey: apiKey);

  _SearchLocationState({
    @required this.onStartPlaceSelected, 
    @required this.onEndPlaceSelected, 
    @required this.markers, 
    @required this.preExecute
  });

  void _execute(String hint, int type) async {
    this.preExecute();
    Prediction prediction = await PlacesAutocomplete.show(
      context: context,
      apiKey: apiKey,
      mode: Mode.overlay,
      hint: hint,
      overlayBorderRadius: BorderRadius.all(Radius.circular(15.0)),
      language: "pt", components: [
        Component(Component.country, "br")
      ]
    );
    if(prediction!=null){
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
                    this._execute("Digite o nome do seu local de partida", 0);
                  }
                ),
                AnimatedSize(
                  vsync: this,
                  curve: Curves.linear,
                  duration: Duration(milliseconds: 200),
                  child: Container(
                    child: showSecond || endControler.text != ""? TextField(
                      controller: endControler,
                      decoration:  new InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        suffixIcon: Icon(Icons.flag),
                        contentPadding: EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                        hintText: "Digite o nome do seu local de destino"
                      ),
                      autofocus: false,
                      enableInteractiveSelection: false,
                      readOnly: true,
                      showCursor: false,
                      onTap: () {
                        this._execute("Digite o nome do seu local de destino", 1);
                      }
                    ): SizedBox()
                  )
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  child: FlatButton(
                    onPressed: endControler.text != ""? null: (){
                      this.preExecute();
                      setState(() {
                        this.showSecond = !this.showSecond;
                      });
                    },
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                    color: Colors.transparent,
                    child:  Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(showSecond || endControler.text != ""? "Ocultar destino":"Mostrar destino", 
                          style: TextStyle(
                            color: endControler.text != ""? Colors.grey :Theme.of(context).primaryColor, 
                            fontSize: 18
                          )
                        ),
                        SizedBox(width: 2),
                        Icon(showSecond || endControler.text != ""?Icons.remove:Icons.add, 
                          color: endControler.text != ""? Colors.grey :Theme.of(context).primaryColor, 
                          size: 18
                        )
                      ],
                    ),
                  )
                )
              ]
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).backgroundColor,
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