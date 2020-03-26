import 'package:flutter_redux/flutter_redux.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:perna/services/user.dart';
import 'package:perna/store/state.dart';
import 'package:perna/widgets/bottomCard.dart';
import 'package:perna/widgets/cardHeader.dart';
import 'package:perna/widgets/timePicker.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

class UserWidget extends StatelessWidget {
  final Set<Marker> userMarkers;
  
  UserWidget({@required this.userMarkers});
  
  @override
  Widget build(BuildContext context) {
    return _UserWidget(userMarkers: userMarkers);
  }
}

class _UserWidget extends StatefulWidget {
  final Set<Marker> userMarkers;

  _UserWidget({ Key key, @required this.userMarkers}) : super(key: key);

  @override
  _UserWidgetState createState() => _UserWidgetState(userMarkers: userMarkers);
}

class _UserWidgetState extends State<_UserWidget> {
  final Set<Marker> userMarkers;
  
  double selectedEndTime = 0.0;
  double selectedStartTime = 0.0;
  UserService userService = new UserService();

  
  _UserWidgetState({@required this.userMarkers});

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
    return BottomCard(
      height: 250,
      children: <Widget>[
        StoreConnector<StoreState, String>(
          converter: (store) {
            return store.state.user.email;
          },
          builder: (context, email){
            return CardHeader(
              addFunction: (){addFunction(this.userMarkers, email);},
              title: "Pedido",
            );
          },
        ),
        SizedBox(height: 10),
        TimePicker(labelText: "Partida", onSelectedTime: onSelectedStartTime),
        SizedBox(height: 20),
        TimePicker(labelText: "Chegada", onSelectedTime: onSelectedEndTime)
      ]
    );
  }

}
