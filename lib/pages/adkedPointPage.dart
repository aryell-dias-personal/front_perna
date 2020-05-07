import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:loading/loading.dart';
import 'package:perna/models/agent.dart';
import 'package:perna/models/askedPoint.dart';
import 'package:perna/pages/expedientPage.dart';
import 'package:perna/services/user.dart';
import 'package:perna/store/state.dart';
import 'package:intl/intl.dart';
import 'package:perna/widgets/formTimePicker.dart';
import 'package:toast/toast.dart';

enum AskedPointOptions { aboutExpedient }

class AskedPointPage extends StatefulWidget {
  final AskedPoint askedPoint;
  final bool readOnly;
  final Function() clear;

  const AskedPointPage({Key key, @required this.askedPoint, @required this.readOnly, @required this.clear}) : super(key: key);

  @override
  _AskedPointPageState createState() => _AskedPointPageState(askedPoint: this.askedPoint, readOnly: this.readOnly, clear: this.clear);
}

class _AskedPointPageState extends State<AskedPointPage> {
  final _formKey = GlobalKey<FormState>();
  final AskedPoint askedPoint;
  final bool readOnly;
  final DateFormat format = DateFormat('hh:mm dd/MM/yyyy');
  final UserService userService = new UserService();
  bool isLoading = false;
  String name;
  String askedEndAt;
  String askedStartAt;
  final Function() clear;

  _AskedPointPageState({@required this.readOnly, @required this.askedPoint, @required this.clear});

  void _onPressed(String email){
    if(_formKey.currentState.validate()){
      setState(() {
        isLoading = true;
      });
      userService.postNewAskedPoint(askedPoint.copyWith(
        askedEndAt: format.parse(askedEndAt),
        askedStartAt: format.parse(askedStartAt),
        name: this.name,
        email: email
        )
      ).then((statusCode){
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
  }

  void _onSelectedAskedPointOptions(Firestore firestore, AskedPointOptions result){
    setState(() {
      this.isLoading = true;
    });
    firestore.collection("agent").document(this.askedPoint.agentId).get().then((DocumentSnapshot documentSnapshot){
      Agent agent = Agent.fromJson(documentSnapshot.data);
      Navigator.push(context, 
        MaterialPageRoute(
          builder: (context) => ExpedientPage(agent: agent, readOnly: true, clear: (){})
        )
      ).whenComplete((){
        setState(() {
          this.isLoading = false;
        });
      });
    }).catchError((error){
      setState(() {
        this.isLoading = false;
      });
      Toast.show(
        "Não foi possivel encontrar o expediente que atende este pedido", context, 
        backgroundColor: Colors.redAccent, 
        duration: 3
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: isLoading ? Center(
        child:Loading(indicator: BallPulseIndicator(), size: 100.0, color: Theme.of(context).primaryColor)
      ) : StoreConnector<StoreState, String>(
        converter: (store) {
          return store.state.user.email;
        },
        builder: (context, email){
          return SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Row(
                        children:<Widget>[
                          Text(
                            "${this.readOnly?"":"Novo "}Pedido",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,  
                              fontSize: 30.0
                            )
                          ),
                          SizedBox(width: 5),
                          Icon(Icons.scatter_plot, size: 30)
                        ] + (this.readOnly && this.askedPoint.agentId != null ? [
                          SizedBox(width: 179.7),
                          StoreConnector<StoreState, Firestore>(
                            converter: (store)=>store.state.firestore, 
                            builder: (context, firestore) => PopupMenuButton<AskedPointOptions>(
                              tooltip: "Mostrar menu",
                              onSelected: (AskedPointOptions result) => this._onSelectedAskedPointOptions(firestore, result),
                              itemBuilder: (BuildContext context) => <PopupMenuEntry<AskedPointOptions>>[
                                PopupMenuItem<AskedPointOptions>(
                                  value: AskedPointOptions.aboutExpedient,
                                  child: Text('Sobre o expediente')
                                )
                              ],
                            )
                          )
                        ]: [])
                      ),
                      SizedBox(height: 26),
                      TextFormField(
                        readOnly: this.readOnly,
                        initialValue: this.askedPoint.name ?? "",
                        onChanged: (text){
                            this.name = text;
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Nome do pedido",
                          suffixIcon: Icon(Icons.short_text)
                        ),
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Digite um nome para seu pedido';
                          }
                          return null;
                        },
                        onFieldSubmitted: (text){
                          FocusScope.of(context).nextFocus();
                        },
                      ),
                      SizedBox(height: 26),
                      FormTimePicker(
                        initialValue: this.askedPoint.askedStartAt,
                        icon: Icons.insert_invitation,
                        labelText: "Deseja Embarcar",
                        onChanged: (text){
                          this.askedStartAt = text;
                        },
                        readOnly: this.readOnly,
                        validatorMessage: 'Digite a hora que deseja embarcar',
                        onSubmit: (text){
                          FocusScope.of(context).nextFocus();
                        }
                      ),
                      SizedBox(height: 26),
                      FormTimePicker(
                        initialValue: this.askedPoint.askedEndAt,
                        onChanged: (text){
                          this.askedEndAt= text;
                        },
                        action: TextInputAction.done,
                        labelText: "Deseja Desembarcar",
                        icon: Icons.insert_invitation,
                        readOnly: this.readOnly,
                        onSubmit: (text){
                          _onPressed(email);
                        },
                        validatorMessage: 'Digite uma hora que deseja desembarcar',
                      ),
                      SizedBox(height: 26)
                    ] + (this.askedPoint.actualStartAt!=null && this.askedPoint.actualEndAt!=null ? [
                      FormTimePicker(
                        readOnly: true,
                        initialValue: this.askedPoint.actualStartAt,
                        labelText: "Hora da partida",
                        icon: Icons.insert_invitation
                      ),
                      SizedBox(height: 26),
                      FormTimePicker(
                        readOnly: true,
                        initialValue: this.askedPoint.actualEndAt,
                        labelText: "Hora da chegada",
                        icon: Icons.insert_invitation
                      ),
                      SizedBox(height: 26)
                    ]: []) + [
                      TextFormField(
                        readOnly: true,
                        initialValue: this.askedPoint.friendlyOrigin,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Local da partida",
                          suffixIcon: Icon(Icons.pin_drop)
                        )
                      ),
                      SizedBox(height: 26),
                      TextFormField(
                        readOnly: true,
                        initialValue: this.askedPoint.friendlyDestiny,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Local da chegada",
                          suffixIcon: Icon(Icons.flag)
                        )
                      ),
                      SizedBox(height: 26),
                      RaisedButton(
                        onPressed: this.readOnly? null : (){
                          _onPressed(email);
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children:<Widget>[
                            Text("Adicionar", style: TextStyle(color: Theme.of(context).backgroundColor, fontSize: 18)),
                            Icon(Icons.add, color: Theme.of(context).backgroundColor, size: 20)
                          ]
                        ),
                        color: Theme.of(context).primaryColor,
                        shape: StadiumBorder(),
                      )
                    ]
                  )
                )
              )
            )
          );
        }
      )
    );
  }
}