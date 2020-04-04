import 'package:flutter_redux/flutter_redux.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:loading/loading.dart';
import 'package:perna/services/driver.dart';
import 'package:perna/store/state.dart';
import 'package:perna/widgets/cardContainer.dart';
import 'package:perna/widgets/timePicker.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:toast/toast.dart';

class ExpedientWidget extends StatelessWidget {
  final Set<Marker> driverMarkers;
  final Function clear;

  ExpedientWidget({@required this.driverMarkers, @required this.clear});

  @override
  Widget build(BuildContext context) {
    return _ExpedientWidget(driverMarkers: this.driverMarkers, clear: this.clear);
  }
}

class _ExpedientWidget extends StatefulWidget {
  final Set<Marker> driverMarkers;
  final Function clear;

  _ExpedientWidget({ Key key, @required this.driverMarkers, @required this.clear}) : super(key: key);

  @override
  _ExpedientWidgetState createState() => _ExpedientWidgetState(driverMarkers: this.driverMarkers, clear: this.clear);
}

class _ExpedientWidgetState extends State<_ExpedientWidget> {
  String name;
  bool isLoading = false;
  final Set<Marker> driverMarkers;
  final Function clear;
  int places = 0; 
  double selectedEndTime;
  double selectedStartTime;
  DateTime selectedEndDateTime;
  DateTime selectedStartDateTime;
  DriverService driverService = new DriverService();
  TextEditingController garageController = TextEditingController();
  TextEditingController numberControler = new TextEditingController();
  final Geolocator _geolocator = Geolocator();

  _ExpedientWidgetState({@required this.driverMarkers, @required this.clear});

  String placemarkToString(Placemark placemark){
    return "${placemark.administrativeArea}, ${placemark.subAdministrativeArea}, ${placemark.subLocality}, ${placemark.thoroughfare}, ${placemark.subThoroughfare}";
  }

  @override
  void initState() {
    setState(() {
      _geolocator.placemarkFromCoordinates(driverMarkers.last.position.latitude, driverMarkers.last.position.longitude).then((placeMarkers){
        Placemark placemark = placeMarkers.first;
        garageController.text = placemarkToString(placemark);
      });
    });
    super.initState();
  }

  void _showDialog() {
    showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return new NumberPickerDialog.integer( minValue: 0,
          maxValue: 1000, title: new Text("Quantas vagas disponíveis?"),
          initialIntegerValue: places);
      }
    ).then((value) {
      if (value != null) {
        setState((){
          places = value;
          numberControler.text = value.toString();
        });
      }
    });
  }

  void onSelectedStartTime(DateTime selectedDate) {
      setState((){
        selectedStartDateTime = selectedDate;
        if(selectedDate!=null){
          selectedStartTime = selectedDate.millisecondsSinceEpoch/60000;
        } else {
          selectedStartTime = null;
        }
      });
  }

  void onSelectedEndTime(DateTime selectedDate) {
    setState((){
      selectedEndDateTime = selectedDate;
      if(selectedDate!=null){
        selectedEndTime = selectedDate.millisecondsSinceEpoch/60000;
      } else {
        selectedEndTime = null;
      }
    });
  }

  void addFunction(garage, email) {
    if(garage != null && places != 0 && this.name != null && this.name != "" && selectedStartTime != null && selectedEndTime != null){
      setState(() {
        isLoading = true;
      });
      String localName = "${garage.position.latitude}, ${garage.position.longitude}"; 
      driverService.postNewAgent(this.name, localName, places, selectedStartTime, selectedEndTime, email).then((statusCode){
        if(statusCode==200){
          Navigator.pop(context);
          this.clear();
          Toast.show(
            "O expediente foi adicionado com sucesso", context, 
            backgroundColor: Colors.greenAccent, 
            duration: 3
          );
        }else{
          setState(() {
            isLoading = false;
          });
          Toast.show(
            "Não foi possivel adicionar o expediente", context, 
            backgroundColor: Colors.redAccent, 
            duration: 3
          );
        } 
      });
    } else {
      Toast.show(
        "preencha todos os campos", context, 
        backgroundColor: Colors.redAccent, 
        duration: 3
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading ? Center(
        child:Loading(indicator: BallPulseIndicator(), size: 100.0)
      ) : CardContainer(
      alignment: Alignment.bottomCenter,
      height: 540,
      children: <Widget>[
        Row(
          children:<Widget>[
            Text(
              "Novo Expediente",
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                color: Theme.of(context).primaryColor,
                fontSize: 30.0
              )
            ),
            SizedBox(width: 5),
            Icon(Icons.work, color: Theme.of(context).primaryColor, size: 30)
          ],
        ),
        TextField(
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: "Nome do expediente",
          ),
          onChanged: (text){
            this.name = text;
          }
        ),
        TimePicker(
          labelText: 'Início do expediente', 
          onSelectedTime: onSelectedStartTime, 
          lastdateTime: selectedEndDateTime
        ),
        TimePicker(
          labelText: 'Fim do expediente', 
          onSelectedTime: onSelectedEndTime, 
          firstDateTime: selectedStartDateTime
        ),
        TextField(
          onTap: _showDialog,
          controller: numberControler,
          readOnly: true,          
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: "Vagas disponíveis",
          )
        ),
        TextField(
          readOnly: true,
          controller: garageController,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: "Local da garagem",
          )
        ),
        StoreConnector<StoreState, String>(
          converter: (store) {
            return store.state.user.email;
          },
          builder: (context, email){
            return RaisedButton(
              onPressed: (){addFunction(this.driverMarkers.first, email);},
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children:<Widget>[
                  Text("Adicionar", style: TextStyle(color: Colors.white, fontSize: 18)),
                  Icon(Icons.add, color: Colors.white, size: 20)
                ]
              ),
              color: Theme.of(context).primaryColor,
              shape: StadiumBorder(),
            );
          }
        ),
      ]
    );
  }

}