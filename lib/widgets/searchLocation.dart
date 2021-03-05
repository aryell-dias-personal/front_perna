import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/directions.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:perna/helpers/appLocalizations.dart';

class SearchLocation extends StatefulWidget {
  final Function() preExecute;
  final Function(Location, String, String) onStartPlaceSelected;
  final Function(Location, String, String) onEndPlaceSelected;
  final Set<Marker> markers;

  const SearchLocation({
    Key key, @required this.onStartPlaceSelected, 
    @required this.onEndPlaceSelected, @required this.markers, 
    @required this.preExecute
  }) : super(key: key);

  @override
  _SearchLocationState createState() => _SearchLocationState();
}

class _SearchLocationState extends State<SearchLocation> with TickerProviderStateMixin {
  bool showSecond = false;
  TextEditingController initialController = TextEditingController();
  TextEditingController endControler = new TextEditingController();

  GoogleMapsPlaces _places = new GoogleMapsPlaces(apiKey: FlavorConfig.instance.variables['apiKey']);

  Future _execute(int position) async {
    widget.preExecute();
    Locale current = AppLocalizations.of(context).locale;
    Prediction prediction = await PlacesAutocomplete.show(
      context: context,
      apiKey: FlavorConfig.instance.variables['apiKey'],
      mode: Mode.overlay,
      hint: AppLocalizations.of(context).translate(position == 0 ? "search_start" : "search_end"),
      overlayBorderRadius: BorderRadius.all(Radius.circular(15.0)),
      language: current.languageCode, components: [
        Component(Component.country, current.countryCode)
      ]
    );
    if(prediction!=null){
      PlacesDetailsResponse placesDetailsResponse = await _places.getDetailsByPlaceId(prediction.placeId);
      Location location = placesDetailsResponse.result.geometry.location;
      Coordinates coordinates = new Coordinates(location.lat, location.lng);
      List<Address> addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
      Address address = addresses.first;
      String region = "${address.subAdminArea}, ${address.adminArea}, ${address.countryName}";
      if(position == 0){
        widget.onStartPlaceSelected(location, prediction.description, region);
        this.initialController.text = prediction.description;
      }else{
        widget.onEndPlaceSelected(location, prediction.description, region);
        this.endControler.text = prediction.description;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      if(widget.markers!=null && widget.markers.length>0) { 
        this.initialController.text = widget.markers.first.infoWindow.snippet;
      } else {
        this.initialController.text = "";
      }
      if(widget.markers!=null && widget.markers.length>1) {
        this.endControler.text = widget.markers.last.infoWindow.snippet;
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
                    hintText: AppLocalizations.of(context).translate("search_start")
                  ),
                  autofocus: false,
                  enableInteractiveSelection: false,
                  readOnly: true,
                  showCursor: false,
                  onTap: () async {
                    await this._execute(0);
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
                        hintText: AppLocalizations.of(context).translate("search_end")
                      ),
                      autofocus: false,
                      enableInteractiveSelection: false,
                      readOnly: true,
                      showCursor: false,
                      onTap: () async {
                        await this._execute(widget.markers.length);
                      }
                    ): SizedBox()
                  )
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  child: FlatButton(
                    onPressed: endControler.text != ""? null: (){
                      widget.preExecute();
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
                        Text(showSecond || endControler.text != ""? AppLocalizations.of(context).translate("hide_end"):
                          AppLocalizations.of(context).translate("show_end"), 
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