import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:loading/loading.dart';
import 'package:perna/helpers/appLocalizations.dart';
import 'package:perna/helpers/creditCard.dart';
import 'package:perna/helpers/showSnackBar.dart';
import 'package:perna/models/agent.dart';
import 'package:perna/models/askedPoint.dart';
import 'package:perna/models/creditCard.dart';
import 'package:perna/pages/askedPointConfirmationPAge.dart';
import 'package:perna/pages/expedientPage.dart';
import 'package:perna/services/driver.dart';
import 'package:perna/services/payments.dart';
import 'package:perna/services/staticMap.dart';
import 'package:perna/services/user.dart';
import 'package:perna/store/state.dart';
import 'package:intl/intl.dart';
import 'package:perna/widgets/addButton.dart';
import 'package:perna/widgets/formContainer.dart';
import 'package:perna/widgets/formDatePicker.dart';
import 'package:perna/widgets/formTimePicker.dart';
import 'package:perna/widgets/outlinedTextFormField.dart';

enum AskedPointOptions { aboutExpedient }

class AskedPointPage extends StatefulWidget {
  final bool readOnly;
  final Function() clear;
  final AskedPoint askedPoint;
  final UserService userService;
  final Future<String> Function() getRefreshToken;

  const AskedPointPage({
    @required this.userService, 
    @required this.readOnly, 
    @required this.askedPoint, 
    @required this.clear, 
    this.getRefreshToken
  });

  @override
  _AskedPointPageState createState() => _AskedPointPageState(
    askedPoint: this.askedPoint
  );
}

class _AskedPointPageState extends State<AskedPointPage> {
  final _formKey = GlobalKey<FormState>();
  final DateFormat format = DateFormat('HH:mm dd/MM/yyyy');
  final DateFormat dateFormat = DateFormat('dd/MM/yyyy');

  AskedPoint askedPoint;
  DateTime initialDateTime = DateTime.now();
  DateTime now = DateTime.now();
  DateTime minTime;
  String date;
  String askedEndAt;
  String askedStartAt;
  bool isLoading = false;
  StaticMapService staticMapService = new StaticMapService();

  _AskedPointPageState({
    @required this.askedPoint, 
  }) {
    initialDateTime = DateTime(initialDateTime.year, initialDateTime.month, initialDateTime.day + 1);
    minTime = initialDateTime;
    date = dateFormat.format(this.askedPoint.date ?? minTime);
    if(this.askedPoint.staticMap == null) {
      staticMapService.getUint8List(
        markerA: askedPoint.origin,
        markerB: askedPoint.destiny,
        route: [
          askedPoint.origin,
          askedPoint.destiny
        ]
      ).then((Uint8List uint8List) {
        setState(() {
          this.askedPoint = this.askedPoint.copyWith(
            staticMap: uint8List
          );
        });
      });
    }
  }

  void _onPressed(String email, PaymentsService paymentsService) async {
    if(_formKey.currentState.validate()){
      setState(() { isLoading = true; });
      String token = await widget.getRefreshToken();
      List<CreditCard> creditCards = await paymentsService.listCard(token);
      if(creditCards.isEmpty) {
        setState(() { isLoading = false; });
        showSnackBar(AppLocalizations.of(context).translate("at_least_one_credit_card"), 
          Colors.redAccent, context);
        return;
      }    
      DateTime dateTime = dateFormat.parse(this.date);
      DateTime askedEndAtTime, askedStartAtTime;
      if(this.askedEndAt != null) {
        String askedEndAtString = this.askedEndAt.length > 5? this.askedEndAt : '${this.askedEndAt} ${this.date}';
        askedEndAtTime = format.parse(askedEndAtString);
      }
      if(this.askedStartAt != null) askedStartAtTime = format.parse('${this.askedStartAt} ${this.date}');
      AskedPoint newAskedPoint =  this.askedPoint.copyWith(
        email: email,
        date: dateTime,
        askedEndAt: askedEndAtTime?.difference(dateTime),
        askedStartAt: askedStartAtTime?.difference(dateTime),
      );
      AskedPoint simulatedAskedPoint = await widget.userService.simulateAskedPoint(newAskedPoint, token);
      
      if(simulatedAskedPoint != null){
        await Navigator.push(context, MaterialPageRoute(
          builder: (context) => AskedPointConfirmationPage(
            askedPoint: simulatedAskedPoint,
            userToken: token,
            paymentsService: paymentsService,
            defaultCreditCard: creditCards.first,
            clear: widget.clear
          )
        ));
        setState(() { isLoading = false; });
      }else{
        setState(() { isLoading = false; });
        showSnackBar(AppLocalizations.of(context).translate("unsuccessfully_simutale_order"), 
          Colors.redAccent, context);
      }
    }
  }

  void _onSelectedAskedPointOptions(FirebaseFirestore firestore, AskedPointOptions result) async {
    setState(() { this.isLoading = true; });
    DocumentSnapshot documentSnapshot = await firestore.collection("agent").doc(this.askedPoint.agentId).get();
    if (documentSnapshot.data().isNotEmpty) {
      Agent agent = Agent.fromJson(documentSnapshot.data());
      await Navigator.push(context, MaterialPageRoute(
        builder: (context) => Scaffold(
          body: StoreConnector<StoreState, DriverService>(
            builder: (context, driverService) => ExpedientPage(
              driverService: driverService,
              agent: agent, 
              readOnly: true, 
              clear: (){}
            ),
            converter: (store)=>store.state.driverService
          )
        )
      ));
    } else {
      showSnackBar(AppLocalizations.of(context).translate("not_found_expedient"), 
        Colors.redAccent, context);
    }
    setState(() { this.isLoading = false; });
  }

  void _updateMinTime(String text) {
    DateTime nextMinTime = this.dateFormat.parse(text);
    String nextAskedEndAt = this.askedEndAt;
    if(this.askedEndAt != null && this.askedStartAt != null) {
      String minTimeString = this.dateFormat.format(this.minTime);
      String askedEndAtString = this.askedEndAt.length > 5? this.askedEndAt : '${this.askedEndAt} $minTimeString';
      DateTime askedEndAtTime = this.format.parse(askedEndAtString);
      Duration shift = nextMinTime.difference(this.minTime);
      DateTime nextAskedEndAtTime = askedEndAtTime.add(shift);
      nextAskedEndAt = this.format.format(nextAskedEndAtTime);
      if(RegExp(text).hasMatch(nextAskedEndAt)) {
        nextAskedEndAt = nextAskedEndAt.split(" ")[0];
      }
    }
    setState(() {
      this.date = text;
      this.minTime = nextMinTime;
      this.askedEndAt = nextAskedEndAt;
    });
  }

  void _updateStartAt(String nextStartAt) {
    String nextAskedEndAt = this.askedEndAt;
    if(this.askedEndAt != null && this.askedStartAt != null) {
      String minTimeString = this.dateFormat.format(this.minTime);
      DateTime oldAskedStartAt = this.format.parse('${this.askedStartAt} $minTimeString');
      DateTime newAskedStartAt = this.format.parse('$nextStartAt $minTimeString');
      String askedEndAtString = this.askedEndAt.length > 5? this.askedEndAt : '${this.askedEndAt} $minTimeString';
      DateTime askedEndAtTime = this.format.parse(askedEndAtString);
      Duration shift = newAskedStartAt.difference(oldAskedStartAt);
      DateTime nextAskedEndAtTime = askedEndAtTime.add(shift);
      nextAskedEndAt = this.format.format(nextAskedEndAtTime);
      if(RegExp(minTimeString).hasMatch(nextAskedEndAt)) {
        nextAskedEndAt = nextAskedEndAt.split(" ")[0];
      }
    }
    setState(() {
      this.askedStartAt = nextStartAt; 
      this.askedEndAt = nextAskedEndAt;
    });
  }

  @override
  Widget build(BuildContext context) => StoreConnector<StoreState, Map<String, dynamic>>(
      converter: (store) => {
        "email": store.state.user.email,
        "firestore": store.state.firestore,
        "paymentsService": store.state.paymentsService 
      },
      builder: (context, resources) => Scaffold( 
        appBar: AppBar(
          brightness: Theme.of(context).brightness,
          centerTitle: true,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children:<Widget>[
              Text(
                AppLocalizations.of(context).translate("order"),
                style: TextStyle(
                  fontWeight: FontWeight.bold,  
                  fontSize: 30.0
                )
              ),
              SizedBox(width: 5),
              Icon(Icons.scatter_plot, size: 30),
            ]
          ),
          backgroundColor: Theme.of(context).backgroundColor,
          iconTheme: IconThemeData(
            color: Theme.of(context).primaryColor
          ),
          textTheme: TextTheme(
            headline6: TextStyle(
              color: Theme.of(context).primaryColor,
              fontSize: 20,
              fontFamily: Theme.of(context).textTheme.headline6.fontFamily
            )
          ),
          actions: widget.readOnly && this.askedPoint.agentId != null ? <Widget>[
            PopupMenuButton(
              tooltip: AppLocalizations.of(context).translate("open_menu"),
              onSelected: (AskedPointOptions result) => this._onSelectedAskedPointOptions(resources["firestore"], result),
              itemBuilder:  (BuildContext context) => <PopupMenuEntry<AskedPointOptions>>[
                PopupMenuItem<AskedPointOptions>(
                  value: AskedPointOptions.aboutExpedient,
                  child: Text(AppLocalizations.of(context).translate("about_expedient"))
                )
              ],
              offset: Offset(0, 50),
            )
          ] : null,
        ),
        body: Material(
          child: isLoading ? Center(
            child:Loading(indicator: BallPulseIndicator(), size: 100.0, color: Theme.of(context).primaryColor)
          ) : SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  height: 180,
                  width: 600,
                  child: Stack(
                    children: <Widget>[
                      Center(
                        child: Loading(indicator: BallPulseIndicator(), size: 100.0, color: Theme.of(context).primaryColor)
                      ),
                      this.askedPoint.staticMap != null ? Image.memory(this.askedPoint.staticMap) : SizedBox()
                    ],
                  )
                ),
                FormContainer(
                  formkey: this._formKey,
                  children: <Widget>[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        FormDatePicker(
                          value: this.date,
                          isRequired: true,
                          initialValue: this.askedPoint.date ?? this.initialDateTime,
                          onChanged: _updateMinTime,
                          action: TextInputAction.next,
                          labelText: AppLocalizations.of(context).translate("date"),
                          icon: Icons.insert_invitation,
                          readOnly: widget.readOnly,
                          onSubmit: (text){ FocusScope.of(context).nextFocus(); },
                          validatorMessage: AppLocalizations.of(context).translate("select_a_date"),
                        ),
                        SizedBox(height: 26),
                      ] + (this.askedPoint.askedStartAt == null && widget.readOnly ? [] : [
                        SizedBox(width: 10),
                        FormTimePicker(
                          isRequired: false,
                          value: this.askedStartAt,
                          minTime: this.initialDateTime,
                          initialValue: this.askedPoint?.date?.add(this.askedPoint.askedStartAt),
                          icon: Icons.access_time,
                          labelText: AppLocalizations.of(context).translate("desired_start"),
                          onChanged: (text){
                            List<String> chuncks = text.split(" "); 
                            String minTimeString = this.dateFormat.format(this.initialDateTime);
                            if(chuncks.length == 2) {
                              minTimeString = chuncks[1];
                            }
                            this._updateStartAt(chuncks[0]);
                            this._updateMinTime(minTimeString);
                          },
                          selectedDay: this.date,
                          lastDay: 31,
                          readOnly: widget.readOnly,
                          validatorMessage: AppLocalizations.of(context).translate("enter_desired_start"),
                          onSubmit: (text) { FocusScope.of(context).nextFocus(); }
                        )
                      ])
                    ),
                    SizedBox(height: 26),
                  ] + (this.askedPoint.askedEndAt == null && widget.readOnly ? [] : [
                    FormTimePicker(
                      isRequired: false,
                      value: this.askedEndAt,
                      minTime: this.minTime,
                      initialValue: this.askedPoint?.date?.add(this.askedPoint.askedEndAt),
                      onChanged: (text){ 
                        String minTimeString = this.dateFormat.format(this.minTime);
                        setState(() {
                          if(RegExp(minTimeString).hasMatch(text)) {
                            this.askedEndAt = text.split(" ")[0];
                          } else {
                            this.askedEndAt = text; 
                          }
                        });
                      },
                      action: TextInputAction.done,
                      selectedDay: this.date,
                      labelText: AppLocalizations.of(context).translate("desired_end"),
                      icon: Icons.access_time,
                      readOnly: widget.readOnly,
                      onSubmit: (text) => _onPressed(resources["email"], resources["paymentsService"]),
                      validatorMessage: AppLocalizations.of(context).translate("enter_desired_end"),
                    ),
                    SizedBox(height: 26)
                  ]) + (this.askedPoint.actualStartAt!=null && this.askedPoint.actualEndAt!=null ? [
                    FormTimePicker(
                      readOnly: true,
                      selectedDay: this.date,
                      initialValue: this.askedPoint.actualStartAt,
                      labelText: AppLocalizations.of(context).translate("actual_start"),
                      icon: Icons.access_time
                    ),
                    SizedBox(height: 26),
                    FormTimePicker(
                      readOnly: true,
                      selectedDay: this.date,
                      initialValue: this.askedPoint.actualEndAt,
                      labelText: AppLocalizations.of(context).translate("actual_end"),
                      icon: Icons.access_time
                    ),
                    SizedBox(height: 26)
                  ]: []) + [
                    OutlinedTextFormField(
                      readOnly: true,
                      initialValue: this.askedPoint.friendlyOrigin,
                      labelText: AppLocalizations.of(context).translate("start_place"),
                      icon: Icons.pin_drop
                    ),
                    SizedBox(height: 26),
                    OutlinedTextFormField(
                      readOnly: true,
                      initialValue: this.askedPoint.friendlyDestiny,
                      labelText: AppLocalizations.of(context).translate("end_place"),
                      icon: Icons.flag
                    ),
                    SizedBox(height: 26),
                  ] + (this.askedPoint.amount != null ? [
                    OutlinedTextFormField(
                      readOnly: true,
                      initialValue: formatAmount(this.askedPoint.amount, this.askedPoint.currency, AppLocalizations.of(context).locale),
                      labelText: AppLocalizations.of(context).translate("price"),
                      icon: Icons.payments_outlined
                    ),
                    SizedBox(height: 26),
                  ] : []) + [
                    AddButton(
                      onPressed: ()=>_onPressed(resources["email"], resources["paymentsService"]),
                      readOnly: widget.readOnly || this.askedPoint.staticMap == null,
                      addAndcontinue: true
                    )
                  ]
                )
            ]
          ),
        )
      )
    )
  );
}