import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:loading/loading.dart';
import 'package:perna/models/agent.dart';
import 'package:perna/services/driver.dart';
import 'package:perna/store/state.dart';
import 'package:intl/intl.dart';
import 'package:perna/widgets/formTimePicker.dart';
import 'package:toast/toast.dart';

class ExpedientPage extends StatefulWidget {
  final Agent agent;
  final bool readOnly;
  final Function() clear;
  final Function() accept;
  final Function() deny;

  const ExpedientPage({Key key, @required this.agent, @required this.readOnly, @required this.clear, this.accept, this.deny}) : super(key: key);

  @override
  _ExpedientState createState() => _ExpedientState(agent: this.agent, readOnly: this.readOnly, clear: this.clear, accept: this.accept, deny: this.deny);
}

class _ExpedientState extends State<ExpedientPage> {
  final _formKey = GlobalKey<FormState>();
  final Agent agent;
  final bool readOnly;
  final DateFormat format = DateFormat('hh:mm dd/MM/yyyy');
  final DriverService driverService = new DriverService();
  final Function() accept;
  final Function() deny;
  final Function() clear;
  bool isLoading = false;
  String name;
  String places;
  String email;
  String askedEndAt;
  String askedStartAt;

  _ExpedientState({@required this.readOnly, @required this.agent, @required this.clear, this.accept, this.deny});

  void askNewAgend(agent) async {
    int statusCode = await driverService.askNewAgent(agent);
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

  void onPressed(String email, String fromEmail){
    if(_formKey.currentState.validate()){
      setState(() {
        isLoading = true;
      });
      Agent agent = this.agent.copyWith(
        askedEndAt: format.parse(askedEndAt),
        askedStartAt: format.parse(askedStartAt),
        name: this.name,
        email: email,
        fromEmail: fromEmail != email ? fromEmail : null,
        places: int.parse(this.places)
      );
      if(fromEmail != email) {
        this.askNewAgend(agent);
      } else {
        driverService.postNewAgent(agent).then((statusCode){
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
  }

  List<Widget> actionButtons(BuildContext context){
    return this.accept==null || this.deny == null? []: [
      SizedBox(height: 10),
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          RaisedButton(
            onPressed: (){
              setState(() {
                isLoading=true; 
              });
              this.accept().then((_){
                setState(() {
                  isLoading=false;
                });
              });
            },
            child: Text("Aceitar", style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white
            )),
            color: Theme.of(context).primaryColor,
            shape: StadiumBorder()
          ),
          RaisedButton(
            onPressed: (){
              setState(() {
                isLoading=true; 
              });
              this.deny().then((_){
                setState(() {
                  isLoading=false;
                });
              });
            },
            child: Text("Negar", style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor
            )),
            color: Colors.white,
            shape: StadiumBorder(),
          )
        ],
      )
    ];
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
        builder: (context, fromEmail){
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
                            "${this.readOnly?"":"Novo "}Expediente",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,  
                              fontSize: 30.0
                            )
                          ),
                          SizedBox(width: 5),
                          Icon(Icons.work, size: 30)
                        ],
                      ),
                      SizedBox(height: 26),
                      TextFormField(
                        readOnly: this.readOnly,
                        initialValue: this.agent.name ?? "",
                        onChanged: (text){
                            this.name = text;
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Nome do expediente",
                          suffixIcon: Icon(Icons.short_text)
                        ),
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Digite um nome para seu expediente';
                          }
                          return null;
                        },
                        onFieldSubmitted: (text){
                          FocusScope.of(context).nextFocus();
                        },
                      ),
                      SizedBox(height: 26),
                      TextFormField(
                        readOnly: this.readOnly,
                        initialValue: this.agent.email ?? "",
                        onChanged: (text){
                          this.email = text;
                        },
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Email do motorista",
                          suffixIcon: Icon(Icons.email)
                        ),
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Digite um nome para seu expediente';
                          }
                          return null;
                        },
                        onFieldSubmitted: (text){
                          FocusScope.of(context).nextFocus();
                        },
                      )
                    ] + (this.agent.fromEmail!=null ? [
                      SizedBox(height: 26),
                      TextFormField(
                        readOnly: true,
                        initialValue: this.agent.fromEmail,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Email do requisitor",
                          suffixIcon: Icon(Icons.email)
                        ),
                      ),
                    ]: []) + [
                      SizedBox(height: 26),
                      FormTimePicker(
                        initialValue: this.agent.askedStartAt,
                        onChanged: (text){
                          this.askedStartAt= text;
                        },
                        action: TextInputAction.next,
                        labelText: "Início do expediente",
                        icon: Icons.calendar_today,
                        readOnly: this.readOnly,
                        onSubmit: (text){
                          FocusScope.of(context).nextFocus();
                        },
                        validatorMessage: 'Digite uma hora de início para o expediente',
                      ),
                      SizedBox(height: 26),
                      FormTimePicker(
                        initialValue: this.agent.askedEndAt,
                        icon: Icons.calendar_today,
                        labelText: "Fim do expediente",
                        onChanged: (text){
                          this.askedEndAt = text;
                        },
                        readOnly: this.readOnly,
                        validatorMessage: 'Digite uma hora de fim para o expediente',
                        onSubmit: (text){
                          FocusScope.of(context).nextFocus();
                        }
                      ),
                      SizedBox(height: 26),
                      TextFormField(
                        readOnly: this.readOnly,
                        initialValue: this.agent.places?.toString() ?? "",
                        onChanged: (text){
                            this.places = text;
                        },
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Número de lugares",
                          suffixIcon: Icon(Icons.airline_seat_legroom_normal)
                        ),
                        textInputAction: TextInputAction.done,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Digite o número de vagas do expediente';
                          }
                          return null;
                        },
                        onFieldSubmitted: (text){
                          onPressed(this.email, fromEmail);
                        },
                      ),
                      SizedBox(height: 26),
                      TextFormField(
                        readOnly: true,
                        initialValue: this.agent.friendlyGarage,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Garagem",
                          suffixIcon: IconButton(
                            splashColor: Colors.transparent,
                            icon:Icon(Icons.pin_drop),
                            onPressed: (){},
                          )
                        ), 
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Digite uma local para sua garagem';
                          }
                          return null;
                        }
                      ),
                      SizedBox(height: 26)
                    ] + ( this.accept != null && this.deny != null && this.readOnly ? this.actionButtons(context) : [
                      RaisedButton(
                        onPressed: this.readOnly? null : (){
                          onPressed(this.email, fromEmail);
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
                      )
                    ])
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