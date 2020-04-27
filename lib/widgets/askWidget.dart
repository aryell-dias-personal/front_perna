import 'package:flutter_redux/flutter_redux.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:loading/loading.dart';
import 'package:perna/models/askedPoint.dart';
import 'package:perna/services/user.dart';
import 'package:perna/store/state.dart';
import 'package:perna/widgets/cardContainer.dart';
import 'package:perna/widgets/timePicker.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

class AskWidget extends StatelessWidget {
  final Set<Marker> userMarkers;
  final Function clear;
  
  AskWidget({@required this.userMarkers, @required this.clear});
  
  @override
  Widget build(BuildContext context) {
    return _AskWidget(userMarkers: userMarkers, clear: this.clear);
  }
}

class _AskWidget extends StatefulWidget {
  final Set<Marker> userMarkers;
  final Function clear;

  _AskWidget({ Key key, @required this.userMarkers, @required this.clear}) : super(key: key);

  @override
  _AskWidgetState createState() => _AskWidgetState(userMarkers: userMarkers, clear: this.clear);
}

class _AskWidgetState extends State<_AskWidget> {
  String name;
  bool isLoading = false;
  final Set<Marker> userMarkers;
  DateTime askedEndAt;
  DateTime askedStartAt;
  UserService userService = new UserService();
  TextEditingController initialController = TextEditingController();
  TextEditingController endControler = new TextEditingController();
  final Geolocator _geolocator = Geolocator();
  final Function clear;

  String placemarkToString(Placemark placemark){
    return "${placemark.administrativeArea}, ${placemark.subAdministrativeArea}, ${placemark.subLocality}, ${placemark.thoroughfare}, ${placemark.subThoroughfare}";
  }

  @override
  void initState() {
    setState(() {
      _geolocator.placemarkFromCoordinates(userMarkers.first.position.latitude, userMarkers.first.position.longitude).then((placeMarkers){
        Placemark placemark = placeMarkers.first;
        initialController.text = this.placemarkToString(placemark);
      });
      _geolocator.placemarkFromCoordinates(userMarkers.last.position.latitude, userMarkers.last.position.longitude).then((placeMarkers){
        Placemark placemark = placeMarkers.first;
        endControler.text = this.placemarkToString(placemark);
      });
    });
    super.initState();
  }

  _AskWidgetState({@required this.userMarkers, @required this.clear});

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

  void addFunction(AskedPoint askedPoint) {

    setState(() {
      isLoading = true;
    });
    userService.postNewAskedPoint(askedPoint).then((statusCode){
      if(statusCode==200){
        Navigator.pop(context);
        this.clear();
        Toast.show(
          "O pedido foi adicionado com sucesso", context, 
          backgroundColor: Colors.greenAccent, 
          duration: 3
        );
      }else{
        setState(() {
          isLoading = false;
        });
        Toast.show(
          "Não foi possivel adicionar o pedido", context, 
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
              "Novo Pedido",
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: 30.0
              )
            ),
            SizedBox(width: 5),
            Icon(Icons.scatter_plot, size: 30)
          ],
        ),
        TextField(
          onChanged: (text){
            this.name = text;
          },
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: "Nome do pedido",
          ), 
        ),
        TimePicker(
          labelText: "Hora da Partida", 
          onSelectedTime: onSelectedStartTime, 
          lastdateTime: askedEndAt
        ),
        TimePicker(
          labelText: "Hora da Chegada", 
          onSelectedTime: onSelectedEndTime, 
          firstDateTime: askedStartAt
        ),
        TextField(
          readOnly: true,
          controller: initialController,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: "Local de Partida",
          )
        ),
        TextField(
          readOnly: true,
          controller: endControler,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: "Local de Chegada",
          )
        ),
        StoreConnector<StoreState, String>(
          converter: (store) {
            return store.state.user.email;
          },
          builder: (context, email){
            return RaisedButton(
              onPressed: (){
                if(AskedPoint.invalidArgs(
                  this.userMarkers.first.position, this.userMarkers.last.position, 
                  this.initialController.text, this.endControler.text, this.name, 
                  this.askedStartAt, this.askedEndAt, email)){
                  Toast.show(
                    "preencha todos os campos", context, 
                    backgroundColor: Colors.redAccent, 
                    duration: 3
                  );
                } else{
                  AskedPoint askedPoint = AskedPoint(
                    askedEndAt: this.askedEndAt, askedStartAt: this.askedStartAt, name: this.name,
                    destiny: this.userMarkers.last.position, origin: this.userMarkers.first.position,
                    email: email, friendlyOrigin: this.initialController.text, friendlyDestiny: this.endControler.text
                  );
                  addFunction(askedPoint);
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
