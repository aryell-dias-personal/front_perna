import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:perna/helpers/app_localizations.dart';

class SearchLocation extends StatefulWidget {
  const SearchLocation({
    Key key, 
    @required this.onStartPlaceSelected, 
    @required this.onEndPlaceSelected, 
    @required this.markers, 
    @required this.preExecute
  }) : super(key: key);

  final Function() preExecute;
  final Function(Coordinates, String, String) onStartPlaceSelected;
  final Function(Coordinates, String, String) onEndPlaceSelected;
  final Set<Marker> markers;

  @override
  _SearchLocationState createState() => _SearchLocationState();
}

class _SearchLocationState extends State<SearchLocation> with TickerProviderStateMixin {
  bool showSecond = false;
  TextEditingController initialController = TextEditingController();
  TextEditingController endControler = TextEditingController();

  final GoogleMapsPlaces _places =
    GoogleMapsPlaces(apiKey: FlavorConfig.instance.variables['apiKey'] as String);

  Future<void> _execute(int position) async {
    widget.preExecute();
    final Locale current = AppLocalizations.of(context).locale;
    final Prediction prediction = await PlacesAutocomplete.show(
      context: context,
      apiKey: FlavorConfig.instance.variables['apiKey'] as String,
      // HACK: esse types e strictbounds tão sem valor default lá dentro, não tira
      types: <String>[],
      strictbounds: false,
      mode: Mode.overlay,
      hint: AppLocalizations.of(context).translate(position == 0 ? 'search_start' : 'search_end'),
      overlayBorderRadius: const BorderRadius.all(Radius.circular(15.0)),
      language: current.languageCode, components: <Component>[
        Component(Component.country, current.countryCode)
      ]
    );
    if(prediction!=null){
      final PlacesDetailsResponse placesDetailsResponse = await _places.getDetailsByPlaceId(prediction.placeId);
      final Location location = placesDetailsResponse.result.geometry.location;
      final Coordinates coordinates = Coordinates(location.lat, location.lng);
      final List<Address> addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
      final Address address = addresses.first;
      final String region = '${address.subAdminArea}, ${address.adminArea}, ${address.countryName}';
      if(position == 0){
        widget.onStartPlaceSelected(coordinates, prediction.description, region);
        initialController.text = prediction.description;
      }else{
        widget.onEndPlaceSelected(coordinates, prediction.description, region);
        endControler.text = prediction.description;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      if(widget.markers!=null && widget.markers.isNotEmpty) { 
        initialController.text = widget.markers.first.infoWindow.snippet;
      } else {
        initialController.text = '';
      }
      if(widget.markers!=null && widget.markers.length>1) {
        endControler.text = widget.markers.last.infoWindow.snippet;
      } else {
        endControler.text = '';
      }
    });
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(left: 15, top: 30, right: 15),
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).backgroundColor,
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: Colors.black38,
                    offset: Offset(1.0, 1.0),
                    blurRadius: 3),
                ],
                borderRadius: const BorderRadius.all(
                  Radius.circular(15.0)
                )
              ),
              child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: initialController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    suffixIcon: const Icon(Icons.pin_drop),
                    contentPadding:
                      const EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                    hintText: AppLocalizations.of(context).translate('search_start')
                  ),
                  enableInteractiveSelection: false,
                  readOnly: true,
                  showCursor: false,
                  onTap: () async {
                    await _execute(0);
                  }
                ),
                AnimatedSize(
                  vsync: this,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    child: showSecond || endControler.text != ''? TextField(
                      controller: endControler,
                      decoration:  InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        suffixIcon: const Icon(Icons.flag),
                        contentPadding: const EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                        hintText: AppLocalizations.of(context).translate('search_end')
                      ),
                      enableInteractiveSelection: false,
                      readOnly: true,
                      showCursor: false,
                      onTap: () async {
                        await _execute(widget.markers.length);
                      }
                    ): const SizedBox()
                  )
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: TextButton(
                    style: ButtonStyle(
                      overlayColor: MaterialStateProperty.all(Theme.of(context).splashColor),
                      shape: MaterialStateProperty.all(
                        const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12)))),
                      backgroundColor: MaterialStateProperty.all(Colors.transparent)
                    ),
                    onPressed: endControler.text != ''? null: (){
                      widget.preExecute();
                      setState(() {
                        showSecond = !showSecond;
                      });
                    },
                    child:  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(showSecond || endControler.text != ''? AppLocalizations.of(context).translate('hide_end'):
                          AppLocalizations.of(context).translate('show_end'), 
                          style: TextStyle(
                            color: endControler.text != ''? Colors.grey :Theme.of(context).primaryColor, 
                            fontSize: 18
                          )
                        ),
                        const SizedBox(width: 2),
                        Icon(showSecond || endControler.text != ''?Icons.remove:Icons.add, 
                          color: endControler.text != ''? Colors.grey :Theme.of(context).primaryColor, 
                          size: 18
                        )
                      ],
                    ),
                  )
                )
              ]
            ),
          ),
        ), 
      )
    );
  }
}