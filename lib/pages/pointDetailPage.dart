import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:loading/loading.dart';
import 'package:perna/models/agent.dart';
import 'package:perna/models/askedPoint.dart';
import 'package:perna/pages/historyPage.dart';
import 'package:perna/store/state.dart';
import 'package:perna/widgets/titledValueWidget.dart';

class PointDetailPage extends StatefulWidget {
  final AskedPoint askedPoint;
  final Agent agent;
  final bool isHome;
  final Future<Null> Function() accept;
  final Future<Null> Function() deny;

  const PointDetailPage({this.askedPoint, this.agent, this.accept, this.deny, this.isHome=false});
  
  @override
  _PointDetailPageState createState() => _PointDetailPageState(
    askedPoint: this.askedPoint, 
    agent: this.agent, 
    accept: this.accept, 
    deny: this.deny, 
    isHome: this.isHome
  );
}

class _PointDetailPageState extends State<PointDetailPage> {
  final AskedPoint askedPoint;
  final Agent agent;
  final bool isHome;
  final Future<Null> Function() accept;
  final Future<Null> Function() deny;
  bool isLoading = false;

  _PointDetailPageState({this.askedPoint, this.agent, this.accept, this.deny, this.isHome=false});

  List<Widget> buildInfo() {
    assert(this.agent != null || this.askedPoint != null);
    return this.agent!=null? buildAgent(): buildAskedPoint();
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

  List<Widget> buildAskedPoint() {
    return <Widget>[
      Text("DETALHES DO PEDIDO", style: TextStyle(color: Color(0xFF1c4966))),
      TitledValueWidget(titleSize: 30, title: "Nome", valueSize: 30, value: this.askedPoint.name),
      getDateInfoWidget(this.askedPoint.askedStartAt.toString(), "Deseja Partir"),
      getDateInfoWidget(this.askedPoint.askedEndAt.toString(), "Deseja Chegar"),
      getDateInfoWidget(this.askedPoint.actualStartAt?.toString(), "Hora do Embarque"),
      getDateInfoWidget(this.askedPoint.actualEndAt?.toString(), "Hora do Desembarque"),
      getLocalInfoWidget(this.askedPoint.friendlyOrigin, "Local da Partida"),
      getLocalInfoWidget(this.askedPoint.friendlyDestiny, "Local da Chegada"),
    ];
  }

  Widget getDateInfoWidget(String date, String name){
    if(date==null) return SizedBox();
    List<String> datePieces = date.split(" ");
    List<String> dayPieces = datePieces.first.split('-');
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(name, style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
        Row(
          children: <Widget>[
            TitledValueWidget(titleSize: 19, title: "Dia", valueSize: 19, value: dayPieces.last),
            SizedBox(width: 5),
            TitledValueWidget(titleSize: 19, title: "Mês", valueSize: 19, value: dayPieces[1]),
            SizedBox(width: 5),
            TitledValueWidget(titleSize: 19, title: "Ano", valueSize: 19, value: dayPieces.first),
            SizedBox(width: 5),
            TitledValueWidget(titleSize: 19, title: "Hora", valueSize: 19, value: datePieces.last.split(':').sublist(0,2).join(':')),
          ],
        ),
      ],
    );
  }
  
  Widget getLocalInfoWidget(String local, String name){
    List<String> localPieces = local.split(",");
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(name, style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
            IconButton(
              icon: Icon(Icons.map),
              onPressed: (){} 
            )
          ]
        ),
        TitledValueWidget(titleSize: 20, title: "Estado", valueSize: 20, value: localPieces.first),
        TitledValueWidget(titleSize: 20, title: "Bairro", valueSize: 20, value: localPieces[2]),
        TitledValueWidget(titleSize: 20, title: "Cidade", valueSize: 20, value: localPieces[1]),
        TitledValueWidget(titleSize: 20, title: "Rua", valueSize: 20, value: localPieces[3]),
        TitledValueWidget(titleSize: 20, title: "Número", valueSize: 20, value: localPieces.last),
      ],
    );
  }

  Widget getAskedBy(String fromEmail){
    if(fromEmail == null) return SizedBox();
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text("Pedido por", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
        TitledValueWidget(titleSize: 20, title: "Email", valueSize: 20, value: fromEmail)
      ],
    );
  }

  List<Widget> buildAgent() {
    return <Widget>[
      Text("DETALHES DO EXPEDIENTE", style: TextStyle(color: Color(0xFF1c4966))),
      TitledValueWidget(titleSize: 30, title: "Nome", valueSize: 30, value: this.agent.name),
      getDateInfoWidget(this.agent.askedStartAt.toString(), "Inicio do Expediente"),
      getDateInfoWidget(this.agent.askedEndAt.toString(), "Fim do Expediente"),
      getLocalInfoWidget(this.agent.friendlyGarage, "Local da Garagem"),
      getAskedBy(agent.fromEmail),
      TitledValueWidget(titleSize: 30, title: "Vagas", valueSize: 30, value: this.agent.places.toString())
    ];
  }

  BoxDecoration _getDecoration(){
    return new BoxDecoration(
      color: Colors.white,
      boxShadow: <BoxShadow>[
        BoxShadow(
          color: Colors.black,
          offset: Offset(1.0, 6.0),
          blurRadius: 10),
      ],
      borderRadius: new BorderRadius.all(
        const Radius.circular(15.0)
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: isLoading ? Center(
        child: Loading(indicator: BallPulseIndicator(), size: 100.0)
      ) : Padding(
        padding: EdgeInsets.fromLTRB(20,30,20,20),
        child: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.topLeft,
              child: FlatButton(
                onPressed: (){
                  if(this.isHome){
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context) => StoreConnector<StoreState, StoreState>(
                          converter: (store) => store.state,
                          builder:  (context, state) => HistoryPage(email: state.user.email, firestore: state.firestore)
                        )
                      )
                    );
                  }else{
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  }
                }, 
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(!this.isHome?Icons.home:Icons.timeline, color: Theme.of(context).iconTheme.color,),
                    SizedBox(width: 2),
                    Text(!this.isHome?"Ir para o mapa":"Ir para histórico", style: Theme.of(context).textTheme.body1)
                  ],
                ),
                color: Colors.white,
                shape: StadiumBorder(),
              )
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                decoration: _getDecoration(),
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: buildInfo() + actionButtons(context),
                  ),
                )
              )
            )
          ],
        )
      )
    );
  }
}