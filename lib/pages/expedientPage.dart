import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:loading/loading.dart';
import 'package:perna/helpers/appLocalizations.dart';
import 'package:perna/helpers/showSnackBar.dart';
import 'package:perna/models/agent.dart';
import 'package:perna/models/user.dart';
import 'package:perna/pages/userProfilePage.dart';
import 'package:perna/services/driver.dart';
import 'package:perna/services/staticMap.dart';
import 'package:perna/store/state.dart';
import 'package:intl/intl.dart';
import 'package:perna/widgets/actionButtons.dart';
import 'package:perna/widgets/addButton.dart';
import 'package:perna/widgets/formContainer.dart';
import 'package:perna/widgets/formDatePicker.dart';
import 'package:perna/widgets/formTimePicker.dart';
import 'package:perna/widgets/outlinedTextFormField.dart';

enum ExpedientOptions { aboutDriver, aboutRequester }

class ExpedientPage extends StatefulWidget {
  final Agent agent;
  final bool readOnly;
  final Function() deny;
  final Function() clear;
  final Function() accept;
  final DriverService driverService;
  final Future<String> Function() getRefreshToken;

  const ExpedientPage({
    @required this.driverService, 
    @required this.readOnly, 
    @required this.agent, 
    @required this.clear, 
    this.getRefreshToken, 
    this.accept, 
    this.deny
  });

  @override
  _ExpedientState createState() => _ExpedientState( 
    agent: this.agent,
  );
}

class _ExpedientState extends State<ExpedientPage> {
  final _formKey = GlobalKey<FormState>();
  final DateFormat format = DateFormat('HH:mm dd/MM/yyyy');
  final DateFormat dateFormat = DateFormat('dd/MM/yyyy');

  Agent agent;
  DateTime initialDateTime = DateTime.now();
  DateTime minTime;
  String date;
  String email;
  String places;
  String askedEndAt;
  String askedStartAt;
  bool isLoading = false;
  StaticMapService staticMapService = new StaticMapService();

  _ExpedientState({
    @required this.agent, 
  }) {
    initialDateTime = DateTime(initialDateTime.year, initialDateTime.month, initialDateTime.day + 1);
    minTime = initialDateTime;
    date = dateFormat.format(this.agent.date ?? minTime);
    if(this.agent.staticMap == null) {
      staticMapService.getUint8List(
        markerA: agent.garage
      ).then((Uint8List uint8List) {
        setState(() {
          this.agent = this.agent.copyWith(
            staticMap: uint8List
          );
        });
      });
    }
  }

  void _askNewAgend(agent) async {
    int statusCode = await widget.driverService.askNewAgent(agent);
    if(statusCode == 200){
      widget.clear();
      Navigator.pop(context);
      showSnackBar(AppLocalizations.of(context).translate("successful_work_order"), 
        Colors.greenAccent, context);
    } else {
      setState(() { isLoading = false; });
      showSnackBar(AppLocalizations.of(context).translate("unsuccessful_work_order"), 
        Colors.redAccent, context);
    }
  }

  void _onPressed(String email, String fromEmail) async {
    if(_formKey.currentState.validate()){
      setState(() { isLoading = true; });
      DateTime dateTime = dateFormat.parse(this.date);
      String askedEndAtString = this.askedEndAt.length > 5? this.askedEndAt : '${this.askedEndAt} ${this.date}';
      DateTime askedEndAtTime = format.parse(askedEndAtString);
      DateTime askedStartAtTime = format.parse('${this.askedStartAt} ${this.date}');
      Agent agent = this.agent.copyWith(
        email: email,
        date: dateTime,
        askedStartAt: askedStartAtTime.difference(dateTime),
        askedEndAt: askedEndAtTime.difference(dateTime),
        fromEmail: fromEmail != email ? fromEmail : null,
        places: int.parse(this.places)
      );
      if(fromEmail != email) {
        this._askNewAgend(agent);
      } else {
        String token = await widget.getRefreshToken();
        int statusCode = await widget.driverService.postNewAgent(agent, token);
        if(statusCode==200){
          widget.clear();
          Navigator.pop(context);
          showSnackBar( AppLocalizations.of(context).translate("successfully_added_expedient"), 
            Colors.greenAccent, context);
        }else{
          setState(() { isLoading = false; });
          showSnackBar(AppLocalizations.of(context).translate("unsuccessfully_added_expedient"), 
            Colors.redAccent, context);
        }
      }
    }
  }

  void _acceptOrDenny(accept){
    setState(() { isLoading=true; });
    (accept? widget.accept(): widget.deny()).then((_){ setState(() { isLoading=false; }); });
  }
  
  void _onSelectedExpedientOptions(FirebaseFirestore firestore, ExpedientOptions result) async {
    setState(() { this.isLoading = true; });
    String email = result == ExpedientOptions.aboutDriver ? this.agent.email : this.agent.fromEmail;
    QuerySnapshot querySnapshot = await firestore.collection("user").where("email", isEqualTo:email).get();
    if(querySnapshot.docs.isNotEmpty){
      User user = User.fromJson(querySnapshot.docs.first.data());
      await Navigator.push(context, 
        MaterialPageRoute(
          builder: (context) => UserProfilePage(user: user)
        )
      );
    } else {
      showSnackBar(AppLocalizations.of(context).translate("not_found_user"), 
        Colors.redAccent, context
      );
    }
    setState(() {
      this.isLoading = false;
    });
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
  Widget build(BuildContext context) {
    return StoreConnector<StoreState, Map<String, dynamic>>(
      converter: (store) => {
        "email": store.state.user.email,
        "firestore": store.state.firestore          
      },
      builder: (context, resources) => Scaffold(
        appBar: AppBar(
          brightness: Theme.of(context).brightness,
          centerTitle: true,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children:<Widget>[
              Text(
                AppLocalizations.of(context).translate("expedient"),
                style: TextStyle(
                  fontWeight: FontWeight.bold,  
                  fontSize: 30.0
                )
              ),
              SizedBox(width: 5),
              Icon(Icons.work, size: 30),
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
          actions: widget.readOnly ? <Widget>[
            PopupMenuButton(
              tooltip: AppLocalizations.of(context).translate("open_menu"),
              onSelected: (ExpedientOptions result) => this._onSelectedExpedientOptions(resources["firestore"], result),
              itemBuilder: (BuildContext context) => <PopupMenuEntry<ExpedientOptions>>[
                PopupMenuItem<ExpedientOptions>(
                  value: ExpedientOptions.aboutDriver,
                  child: Text(AppLocalizations.of(context).translate("about_driver"))
                ),
                this.agent.fromEmail != null ? PopupMenuItem<ExpedientOptions>(
                  value: ExpedientOptions.aboutRequester,
                  child: Text(AppLocalizations.of(context).translate("about_requester"))
                ): null
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
                      this.agent.staticMap != null ? Image.memory(this.agent.staticMap) : SizedBox()
                    ],
                  )
                ),
                FormContainer(
                    formkey: this._formKey,
                    children: <Widget>[
                      OutlinedTextFormField(
                        readOnly: widget.readOnly,
                        initialValue: this.agent.email ?? "",
                        onChanged: (text){ this.email = text; },
                        textInputType: TextInputType.emailAddress,
                        labelText: AppLocalizations.of(context).translate("driver_email"),
                        icon: Icons.email,
                        textInputAction: TextInputAction.next,
                        validatorMessage: AppLocalizations.of(context).translate("enter_driver_email"),
                        onFieldSubmitted: (text){ FocusScope.of(context).nextFocus(); },
                      )
                    ] + (this.agent.fromEmail!=null ? [
                      SizedBox(height: 26),
                      OutlinedTextFormField(
                        readOnly: true,
                        initialValue: this.agent.fromEmail,
                        textInputType: TextInputType.emailAddress,
                        labelText: AppLocalizations.of(context).translate("requester_email"),
                        icon: Icons.email
                      ),
                    ]: []) + [
                      SizedBox(height: 26),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          FormDatePicker(
                            value: this.date,
                            isRequired: true,
                            initialValue: initialDateTime,
                            onChanged: _updateMinTime,
                            action: TextInputAction.next,
                            labelText: AppLocalizations.of(context).translate("date"),
                            icon: Icons.insert_invitation,
                            readOnly: widget.readOnly,
                            onSubmit: (text){ FocusScope.of(context).nextFocus(); },
                            validatorMessage: AppLocalizations.of(context).translate("select_a_date"),
                          ),
                          SizedBox(width: 10),
                          FormTimePicker(
                            isRequired: true,
                            minTime: initialDateTime,
                            onChanged: (text){
                              List<String> chuncks = text.split(" "); 
                              String minTimeString = this.dateFormat.format(initialDateTime);
                              if(chuncks.length == 2) {
                                minTimeString = chuncks[1];
                              }
                              this._updateStartAt(chuncks[0]);
                              this._updateMinTime(minTimeString);
                            },
                            selectedDay: this.date,
                            value: this.askedStartAt,
                            lastDay: 31,
                            initialValue: this.agent?.date?.add(this.agent.askedStartAt),
                            action: TextInputAction.next,
                            labelText: AppLocalizations.of(context).translate("expedient_start"),
                            icon: Icons.access_time,
                            readOnly: widget.readOnly,
                            onSubmit: (text){ FocusScope.of(context).nextFocus(); },
                            validatorMessage: AppLocalizations.of(context).translate("enter_start_expedient"),
                          ),
                        ]
                      ),
                      SizedBox(height: 26),
                      FormTimePicker(
                        isRequired: true,
                        minTime: minTime,
                        selectedDay: this.date,
                        value: this.askedEndAt,
                        initialValue: this.agent?.date?.add(this.agent.askedEndAt),
                        icon: Icons.access_time,
                        labelText: AppLocalizations.of(context).translate("expedient_end"),
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
                        readOnly: widget.readOnly,
                        validatorMessage: AppLocalizations.of(context).translate("enter_end_expedient"),
                        onSubmit: (text){ FocusScope.of(context).nextFocus(); }
                      ),
                      SizedBox(height: 26),
                      OutlinedTextFormField(
                        readOnly: widget.readOnly,
                        initialValue: this.agent.places?.toString() ?? "",
                        onChanged: (text){ this.places = text; },
                        textInputType: TextInputType.number,
                        labelText: AppLocalizations.of(context).translate("seats_number"),
                        icon: Icons.airline_seat_legroom_normal,
                        textInputAction: TextInputAction.done,
                        validatorMessage: AppLocalizations.of(context).translate("enter_seats_number"),
                        onFieldSubmitted: (text){ this._onPressed(this.email, resources['email']); },
                      ),
                      SizedBox(height: 26),
                      OutlinedTextFormField(
                        readOnly: true,
                        initialValue: this.agent.friendlyGarage,
                        labelText: AppLocalizations.of(context).translate("garage"),
                        icon: Icons.pin_drop
                      ),
                      SizedBox(height: 26)
                    ] + ( widget.accept != null && widget.deny != null && widget.readOnly ? [
                      ActionButtons(
                        accept: (){ _acceptOrDenny(true); },
                        deny: (){ _acceptOrDenny(false); }
                      )
                    ] : [
                      AddButton(
                        onPressed: () => this._onPressed(this.email, resources['email']),
                        readOnly: widget.readOnly || this.agent.staticMap == null,
                      ),
                    ])
                  )
              ]
            )
          )
        ),
      )
    );
  }
}