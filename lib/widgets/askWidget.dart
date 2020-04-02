import 'package:flutter_redux/flutter_redux.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:perna/services/user.dart';
import 'package:perna/store/state.dart';
import 'package:perna/widgets/cardContainer.dart';
import 'package:perna/widgets/timePicker.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

class AskWidget extends StatelessWidget {
  final Set<Marker> userMarkers;
  
  AskWidget({@required this.userMarkers});
  
  @override
  Widget build(BuildContext context) {
    return _AskWidget(userMarkers: userMarkers);
  }
}

class _AskWidget extends StatefulWidget {
  final Set<Marker> userMarkers;

  _AskWidget({ Key key, @required this.userMarkers}) : super(key: key);

  @override
  _AskWidgetState createState() => _AskWidgetState(userMarkers: userMarkers);
}

class _AskWidgetState extends State<_AskWidget> {
  String name;
  final Set<Marker> userMarkers;
  double selectedEndTime = 0.0;
  double selectedStartTime = 0.0;
  DateTime selectedEndDateTime;
  DateTime selectedStartDateTime;
  UserService userService = new UserService();
  TextEditingController initialController = TextEditingController();
  TextEditingController endControler = new TextEditingController();
  final Geolocator _geolocator = Geolocator();

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

  _AskWidgetState({@required this.userMarkers});

  void onSelectedStartTime(DateTime selectedDate) {
    if(selectedDate!=null){
      setState((){
        selectedStartDateTime = selectedDate;
        selectedStartTime = selectedDate.millisecondsSinceEpoch/60000;
      });
    }
  }

  void onSelectedEndTime(DateTime selectedDate) {
    if(selectedDate!=null){
      setState((){
        selectedEndDateTime = selectedDate;
        selectedEndTime = selectedDate.millisecondsSinceEpoch/60000;
      });
    }
  }

  void addFunction(Set<Marker> userMarkers, email) {
    if(userMarkers.length == 2){
      String origin = "${userMarkers.first.position.latitude}, ${userMarkers.first.position.longitude}";
      String destiny = "${userMarkers.last.position.latitude}, ${userMarkers.last.position.longitude}"; 
      userService.postNewAskedPoint(this.name, origin, destiny, this.selectedStartTime, this.selectedEndTime, email).then((statusCode){
        if(statusCode==200){
          Toast.show(
            "O pedido foi adicionado com sucesso", context, 
            backgroundColor: Colors.greenAccent, 
            duration: 3
          );
        }else{
          Toast.show(
            "Não foi possivel adicionar o pedido", context, 
            backgroundColor: Colors.redAccent, 
            duration: 3
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      alignment: Alignment.bottomCenter,
      height: 540,
      children: <Widget>[
        Row(
          children:<Widget>[
            Text(
              "Novo Pedido",
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                color: Theme.of(context).primaryColor,
                fontSize: 30.0
              )
            ),
            SizedBox(width: 5),
            Icon(Icons.scatter_plot, color: Theme.of(context).primaryColor, size: 30)
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
          lastdateTime: selectedEndDateTime
        ),
        TimePicker(
          labelText: "Hora da Chegada", 
          onSelectedTime: onSelectedEndTime, 
          firstDateTime: selectedStartDateTime
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
              onPressed: (){addFunction(this.userMarkers, email);},
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
