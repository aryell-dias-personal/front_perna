import 'package:flutter_redux/flutter_redux.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:perna/services/driver.dart';
import 'package:perna/store/state.dart';
import 'package:perna/widgets/bottomCard.dart';
import 'package:perna/widgets/cardHeader.dart';
import 'package:perna/widgets/timePicker.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:toast/toast.dart';

class DriverWidget extends StatelessWidget {
  final Set<Marker> driverMarkers;

  DriverWidget({@required this.driverMarkers});

  @override
  Widget build(BuildContext context) {
    return _DriverWidget(driverMarkers: driverMarkers);
  }
}

class _DriverWidget extends StatefulWidget {
  final Set<Marker> driverMarkers;

  _DriverWidget({ Key key, @required this.driverMarkers}) : super(key: key);

  @override
  _DriverWidgetState createState() => _DriverWidgetState(driverMarkers: driverMarkers);
}

class _DriverWidgetState extends State<_DriverWidget> {
  final Set<Marker> driverMarkers;
  int places = 0; 
  double selectedEndTime = 0.0;
  double selectedStartTime = 0.0;
  DriverService driverService = new DriverService();
  TextEditingController numberControler = new TextEditingController();

  _DriverWidgetState({@required this.driverMarkers});

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
      selectedStartTime = selectedDate.millisecondsSinceEpoch/60000;
    });
  }

  void onSelectedEndTime(DateTime selectedDate) {
    setState((){
      selectedEndTime = selectedDate.millisecondsSinceEpoch/60000;
    });
  }

  void addFunction(garage, email) {
    if(garage != null){
      String localName = "${garage.position.latitude}, ${garage.position.longitude}"; 
      driverService.postNewAgent(localName, places, selectedStartTime, selectedEndTime, email).then((statusCode){
        if(statusCode==200){
          Toast.show(
            "O expediente foi adicionado com sucesso", context, 
            backgroundColor: Colors.greenAccent, 
            duration: 3
          );
        }else{
          Toast.show(
            "Não foi possivel adicionar o expediente", context, 
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
      height: 330,
      children: <Widget>[
         StoreConnector<StoreState, String>(
          converter: (store) {
            return store.state.user.email;
          },
          builder: (context, email){
            return CardHeader(
              addFunction: (){
                 addFunction(this.driverMarkers, email); 
              },
              title: "Expediente",
            );
          },
        ),
        SizedBox(height: 10),
        TimePicker(labelText: 'Início', onSelectedTime: onSelectedStartTime),
        SizedBox(height: 20),
        TimePicker(labelText: 'Fim', onSelectedTime: onSelectedEndTime),
        SizedBox(height: 20),
        TextField(
          onTap: _showDialog,
          controller: numberControler,
          readOnly: true,          
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: "Vagas",
          )
        )
      ]
    );
  }

}