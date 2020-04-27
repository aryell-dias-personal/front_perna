import 'package:flutter_redux/flutter_redux.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:loading/loading.dart';
import 'package:perna/models/agent.dart';
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
  String driverEmail;
  bool isLoading = false;
  final Set<Marker> driverMarkers;
  final Function clear;
  int places = 0; 
  DateTime askedEndAt;
  DateTime askedStartAt;
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
        askedStartAt = selectedDate;
      });
  }

  void onSelectedEndTime(DateTime selectedDate) {
    setState((){
      askedEndAt = selectedDate;
    });
  }

  void askNewAgend(agent, fromEmail) async {
    setState(() {
      isLoading = true;
    });
    int statusCode = await driverService.askNewAgent(agent, fromEmail);
    if(statusCode == 200){
      Navigator.pop(context);
      this.clear();
      Toast.show(
        "O pedido de expediente foi feito com sucesso", context, 
        backgroundColor: Colors.greenAccent, 
        duration: 3
      );
    } else {
      setState(() {
        isLoading = false;
      });
      Toast.show(
        "Não foi possível fazer o pedido", context, 
        backgroundColor: Colors.redAccent, 
        duration: 3
      );
    }
  }

  void addFunction(Agent agent) {
    setState(() {
      isLoading = true;
    });
    driverService.postNewAgent(agent).then((statusCode){
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
  }

  @override
  Widget build(BuildContext context) {
    return isLoading ? Center(
        child:Loading(indicator: BallPulseIndicator(), size: 100.0)
      ) : CardContainer(
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        Row(
          children:<Widget>[
            Text(
              "Novo Expediente",
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: 30.0
              )
            ),
            SizedBox(width: 5),
            Icon(Icons.work, size: 30)
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
        TextField(
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: "Email do motorista",
          ),
          onChanged: (text){
            this.driverEmail = text;
          }
        ),
        TimePicker(
          labelText: 'Início do expediente', 
          onSelectedTime: onSelectedStartTime, 
          lastdateTime: askedEndAt
        ),
        TimePicker(
          labelText: 'Fim do expediente', 
          onSelectedTime: onSelectedEndTime, 
          firstDateTime: askedStartAt
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
              onPressed: (){
                if(Agent.invalidArgs(
                  this.driverMarkers.first.position, 
                  this.garageController.text, this.places, 
                  this.name, this.askedStartAt, this.askedEndAt, email)){
                  Toast.show(
                    "preencha todos os campos", context, 
                    backgroundColor: Colors.redAccent, 
                    duration: 3
                  );
                } else{
                  Agent agent = Agent(
                    askedEndAt: this.askedEndAt, 
                    askedStartAt: this.askedStartAt,
                    email: this.driverEmail, friendlyGarage: this.garageController.text,
                    garage: this.driverMarkers.first.position, name: this.name, 
                    places: this.places
                  );
                  if(this.driverEmail == email){
                    addFunction(agent);
                  } else {
                    askNewAgend(agent, email);
                  }
                } 
              },
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