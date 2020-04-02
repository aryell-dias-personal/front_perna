import 'package:flutter_redux/flutter_redux.dart';
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
  final Set<Marker> userMarkers;
  
  double selectedEndTime = 0.0;
  double selectedStartTime = 0.0;
  UserService userService = new UserService();

  
  _AskWidgetState({@required this.userMarkers});

  void onSelectedStartTime(DateTime selectedDate) {
    setState((){
      selectedStartTime = selectedDate.millisecondsSinceEpoch/60000;
    });
  }

  void onSelectedEndTime(DateTime selectedDate) {
    setState((){
      selectedEndTime = selectedDate.millisecondsSinceEpoch/60000;
    });
  }

  void addFunction(Set<Marker> userMarkers, email) {
    if(userMarkers.length == 2){
      String origin = "${userMarkers.first.position.latitude}, ${userMarkers.first.position.longitude}";
      String destiny = "${userMarkers.last.position.latitude}, ${userMarkers.last.position.longitude}"; 
      userService.postNewAskedPoint(origin, destiny, this.selectedStartTime, this.selectedEndTime, email).then((statusCode){
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
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: "Nome do pedido",
          )
        ),
        TimePicker(labelText: "Hora da Partida", onSelectedTime: onSelectedStartTime),
        TimePicker(labelText: "Hora da Chegada", onSelectedTime: onSelectedEndTime),
        TextField(
          // readOnly: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: "Local de Partida",
          )
        ),
        TextField(
          // readOnly: true,
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
              child: Icon(Icons.add, color: Colors.white),
              color: Theme.of(context).primaryColor,
              shape: StadiumBorder(),
            );
          }
        ),
      ]
    );
  }

}
