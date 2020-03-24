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
  @override
  Widget build(BuildContext context) {
    return _UserWidget();
  }
}

class _UserWidget extends StatefulWidget {
  _UserWidget({ Key key}) : super(key: key);

  @override
  _UsertState createState() => _UsertState();
}

class _UsertState extends State<_UserWidget> {
  double selectedEndTime = 0.0;
  double selectedStartTime = 0.0;
  UserService userService = new UserService();

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
        StoreConnector<StoreState, Map<String, dynamic>>(
          converter: (store) {
            return {
              'userMarkers': store.state.userMarkers,
              'email': store.state.currentUser.email
            };
          },
          builder: (context, resources){
            return CardHeader(
              addFunction: (){addFunction(resources['userMarkers'], resources['email']);},
              listFunction: (){},
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
