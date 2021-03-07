import 'dart:typed_data';
import 'package:redux/redux.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:loading/loading.dart';
import 'package:perna/helpers/app_localizations.dart';
import 'package:perna/helpers/show_snack_bar.dart';
import 'package:perna/models/agent.dart';
import 'package:perna/models/user.dart';
import 'package:perna/pages/user_profile_page.dart';
import 'package:perna/services/driver.dart';
import 'package:perna/services/static_map.dart';
import 'package:perna/store/state.dart';
import 'package:intl/intl.dart';
import 'package:perna/widgets/action_buttons.dart';
import 'package:perna/widgets/add_button.dart';
import 'package:perna/widgets/form_container.dart';
import 'package:perna/widgets/form_date_picker.dart';
import 'package:perna/widgets/form_time_picker.dart';
import 'package:perna/widgets/outlined_text_form_field.dart';

enum ExpedientOptions { aboutDriver, aboutRequester }

class ExpedientPage extends StatefulWidget {
  const ExpedientPage({
    @required this.driverService, 
    @required this.readOnly, 
    @required this.agent, 
    @required this.clear, 
    this.getRefreshToken, 
    this.accept, 
    this.deny
  });

  final Agent agent;
  final bool readOnly;
  final Function() deny;
  final Function() clear;
  final Function() accept;
  final DriverService driverService;
  final Future<String> Function() getRefreshToken;
  
  @override
  _ExpedientState createState() => _ExpedientState( 
    agent: agent,
  );
}

class _ExpedientState extends State<ExpedientPage> {
  _ExpedientState({
    @required this.agent, 
  }) {
    initialDateTime = DateTime(initialDateTime.year, initialDateTime.month, initialDateTime.day + 1);
    minTime = initialDateTime;
    date = dateFormat.format(agent.date ?? minTime);
    if(agent.staticMap == null) {
      staticMapService.getUint8List(
        markerA: agent.garage
      ).then((Uint8List uint8List) {
        setState(() {
          agent = agent.copyWith(
            staticMap: uint8List
          );
        });
      });
    }
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
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
  StaticMapService staticMapService = StaticMapService();

  Future<dynamic> _askNewAgend(Agent agent) async {
    final int statusCode = await widget.driverService.askNewAgent(agent);
    if(statusCode == 200){
      widget.clear();
      Navigator.pop(context);
      showSnackBar(AppLocalizations.of(context).translate('successful_work_order'), 
        Colors.greenAccent, context);
    } else {
      setState(() { isLoading = false; });
      showSnackBar(AppLocalizations.of(context).translate('unsuccessful_work_order'), 
        Colors.redAccent, context);
    }
  }

  Future<dynamic> _onPressed(String email, String fromEmail) async {
    if(_formKey.currentState.validate()){
      setState(() { isLoading = true; });
      final DateTime dateTime = dateFormat.parse(date);
      final String askedEndAtString = askedEndAt.length > 5? askedEndAt : '$askedEndAt $date';
      final DateTime askedEndAtTime = format.parse(askedEndAtString);
      final DateTime askedStartAtTime = format.parse('$askedStartAt $date');
      final Agent agent = this.agent.copyWith(
        email: email,
        date: dateTime,
        askedStartAt: askedStartAtTime.difference(dateTime),
        askedEndAt: askedEndAtTime.difference(dateTime),
        fromEmail: fromEmail != email ? fromEmail : null,
        places: int.parse(places)
      );
      if(fromEmail != email) {
        _askNewAgend(agent);
      } else {
        final String token = await widget.getRefreshToken();
        final int statusCode = await widget.driverService.postNewAgent(agent, token);
        if(statusCode==200){
          widget.clear();
          Navigator.pop(context);
          showSnackBar( AppLocalizations.of(context).translate('successfully_added_expedient'), 
            Colors.greenAccent, context);
        }else{
          setState(() { isLoading = false; });
          showSnackBar(AppLocalizations.of(context).translate('unsuccessfully_added_expedient'), 
            Colors.redAccent, context);
        }
      }
    }
  }

  void _acceptOrDenny(bool accept){
    setState(() { isLoading=true; });
    (accept? widget.accept(): widget.deny()).then((_){ setState(() { isLoading=false; }); });
  }
  
  Future<dynamic> _onSelectedExpedientOptions(FirebaseFirestore firestore, ExpedientOptions result) async {
    setState(() { isLoading = true; });
    final String email = result == ExpedientOptions.aboutDriver ? agent.email : agent.fromEmail;
    final QuerySnapshot querySnapshot = await firestore.collection('user').where('email', isEqualTo:email).get();
    if(querySnapshot.docs.isNotEmpty){
      final User user = User.fromJson(querySnapshot.docs.first.data());
      await Navigator.push(context, 
        MaterialPageRoute<UserProfilePage>(
          builder: (BuildContext context) => UserProfilePage(user: user)
        )
      );
    } else {
      showSnackBar(AppLocalizations.of(context).translate('not_found_user'), 
        Colors.redAccent, context
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  void _updateMinTime(String text) {
    final DateTime nextMinTime = dateFormat.parse(text);
    String nextAskedEndAt = askedEndAt;
    if(askedEndAt != null && askedStartAt != null) {
      final String minTimeString = dateFormat.format(minTime);
      final String askedEndAtString = askedEndAt.length > 5? askedEndAt : '$askedEndAt $minTimeString';
      final DateTime askedEndAtTime = format.parse(askedEndAtString);
      final Duration shift = nextMinTime.difference(minTime);
      final DateTime nextAskedEndAtTime = askedEndAtTime.add(shift);
      nextAskedEndAt = format.format(nextAskedEndAtTime);
      if(RegExp(text).hasMatch(nextAskedEndAt)) {
        nextAskedEndAt = nextAskedEndAt.split(' ')[0];
      }
    }
    setState(() {
      date = text;
      minTime = nextMinTime;
      askedEndAt = nextAskedEndAt;
    });
  }
  
  void _updateStartAt(String nextStartAt) {
    String nextAskedEndAt = askedEndAt;
    if(askedEndAt != null && askedStartAt != null) {
      final String minTimeString = dateFormat.format(minTime);
      final DateTime oldAskedStartAt = format.parse('$askedStartAt $minTimeString');
      final DateTime newAskedStartAt = format.parse('$nextStartAt $minTimeString');
      final String askedEndAtString = askedEndAt.length > 5? askedEndAt : '$askedEndAt $minTimeString';
      final DateTime askedEndAtTime = format.parse(askedEndAtString);
      final Duration shift = newAskedStartAt.difference(oldAskedStartAt);
      final DateTime nextAskedEndAtTime = askedEndAtTime.add(shift);
      nextAskedEndAt = format.format(nextAskedEndAtTime);
      if(RegExp(minTimeString).hasMatch(nextAskedEndAt)) {
        nextAskedEndAt = nextAskedEndAt.split(' ')[0];
      }
    }
    setState(() {
      askedStartAt = nextStartAt; 
      askedEndAt = nextAskedEndAt;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<StoreState, Map<String, dynamic>>(
      converter: (Store<StoreState> store) => <String, dynamic>{
        'email': store.state.user.email,
        'firestore': store.state.firestore          
      },
      builder: (BuildContext context, Map<String, dynamic> resources) => Scaffold(
        appBar: AppBar(
          brightness: Theme.of(context).brightness,
          centerTitle: true,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children:<Widget>[
              Text(
                AppLocalizations.of(context).translate('expedient'),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,  
                  fontSize: 30.0
                )
              ),
              const SizedBox(width: 5),
              const Icon(Icons.work, size: 30),
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
            PopupMenuButton<ExpedientOptions>(
              tooltip: AppLocalizations.of(context).translate('open_menu'),
              onSelected: (ExpedientOptions result) => _onSelectedExpedientOptions(resources['firestore'], result),
              itemBuilder: (BuildContext context) => <PopupMenuEntry<ExpedientOptions>>[
                PopupMenuItem<ExpedientOptions>(
                  value: ExpedientOptions.aboutDriver,
                  child: Text(AppLocalizations.of(context).translate('about_driver'))
                ),
                if(agent.fromEmail != null) PopupMenuItem<ExpedientOptions>(
                  value: ExpedientOptions.aboutRequester,
                  child: Text(AppLocalizations.of(context).translate('about_requester'))
                )
              ],
              offset: const Offset(0, 50),
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
                SizedBox(
                  height: 180,
                  width: 600,
                  child: Stack(
                    children: <Widget>[
                      Center(
                        child: Loading(indicator: BallPulseIndicator(), size: 100.0, color: Theme.of(context).primaryColor)
                      ),
                      if(agent.staticMap != null) Image.memory(agent.staticMap)
                    ],
                  )
                ),
                FormContainer(
                    formkey: _formKey,
                    children: <Widget>[
                      OutlinedTextFormField(
                        readOnly: widget.readOnly,
                        initialValue: (agent.email ?? email) ?? '',
                        onChanged: (String text){ email = text; },
                        textInputType: TextInputType.emailAddress,
                        labelText: AppLocalizations.of(context).translate('driver_email'),
                        icon: Icons.email,
                        textInputAction: TextInputAction.next,
                        validatorMessage: AppLocalizations.of(context).translate('enter_driver_email'),
                        onFieldSubmitted: (String text){ FocusScope.of(context).nextFocus(); },
                      )
                    ] + (agent.fromEmail!=null ? <Widget>[
                      const SizedBox(height: 26),
                      OutlinedTextFormField(
                        readOnly: true,
                        initialValue: agent.fromEmail,
                        textInputType: TextInputType.emailAddress,
                        labelText: AppLocalizations.of(context).translate('requester_email'),
                        icon: Icons.email
                      ),
                    ]: <Widget>[]) + <Widget>[
                      const SizedBox(height: 26),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          FormDatePicker(
                            value: date,
                            isRequired: true,
                            initialValue: initialDateTime,
                            onChanged: _updateMinTime,
                            labelText: AppLocalizations.of(context).translate('date'),
                            icon: Icons.insert_invitation,
                            readOnly: widget.readOnly,
                            onSubmit: (String text){ FocusScope.of(context).nextFocus(); },
                            validatorMessage: AppLocalizations.of(context).translate('select_a_date'),
                          ),
                          const SizedBox(width: 10),
                          FormTimePicker(
                            isRequired: true,
                            minTime: initialDateTime,
                            onChanged: (String text){
                              final List<String> chuncks = text.split(' '); 
                              String minTimeString = dateFormat.format(initialDateTime);
                              if(chuncks.length == 2) {
                                minTimeString = chuncks[1];
                              }
                              _updateStartAt(chuncks[0]);
                              _updateMinTime(minTimeString);
                            },
                            selectedDay: date,
                            value: askedStartAt,
                            lastDay: 31,
                            initialValue: agent?.date?.add(agent.askedStartAt),
                            labelText: AppLocalizations.of(context).translate('expedient_start'),
                            icon: Icons.access_time,
                            readOnly: widget.readOnly,
                            onSubmit: (String text){ FocusScope.of(context).nextFocus(); },
                            validatorMessage: AppLocalizations.of(context).translate('enter_start_expedient'),
                          ),
                        ]
                      ),
                      const SizedBox(height: 26),
                      FormTimePicker(
                        isRequired: true,
                        minTime: minTime,
                        selectedDay: date,
                        value: askedEndAt,
                        initialValue: agent?.date?.add(agent.askedEndAt),
                        icon: Icons.access_time,
                        labelText: AppLocalizations.of(context).translate('expedient_end'),
                        onChanged: (String text){ 
                          final String minTimeString = dateFormat.format(minTime);
                          setState(() {
                            if(RegExp(minTimeString).hasMatch(text)) {
                              askedEndAt = text.split(' ')[0];
                            } else {
                              askedEndAt = text; 
                            }
                          });
                        },
                        readOnly: widget.readOnly,
                        validatorMessage: AppLocalizations.of(context).translate('enter_end_expedient'),
                        onSubmit: (String text){ FocusScope.of(context).nextFocus(); }
                      ),
                      const SizedBox(height: 26),
                      OutlinedTextFormField(
                        readOnly: widget.readOnly,
                        initialValue: (agent.places?.toString() ?? places?.toString()) ?? '',
                        onChanged: (String text) { places = text; },
                        textInputType: TextInputType.number,
                        labelText: AppLocalizations.of(context).translate('seats_number'),
                        icon: Icons.airline_seat_legroom_normal,
                        textInputAction: TextInputAction.done,
                        validatorMessage: AppLocalizations.of(context).translate('enter_seats_number'),
                        onFieldSubmitted: (String text) { _onPressed(email, resources['email'] as String); },
                      ),
                      const SizedBox(height: 26),
                      OutlinedTextFormField(
                        readOnly: true,
                        initialValue: agent.friendlyGarage,
                        labelText: AppLocalizations.of(context).translate('garage'),
                        icon: Icons.pin_drop
                      ),
                      const SizedBox(height: 26)
                    ] + ( widget.accept != null && widget.deny != null && widget.readOnly ? <Widget>[
                      ActionButtons(
                        accept: (){ _acceptOrDenny(true); },
                        deny: (){ _acceptOrDenny(false); }
                      )
                    ] : <Widget>[
                      AddButton(
                        onPressed: () => _onPressed(
                          email, resources['email'] as String),
                        readOnly: widget.readOnly || agent.staticMap == null,
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