import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
import 'package:perna/store/state.dart';
import 'package:intl/intl.dart';
import 'package:perna/widgets/actionButtons.dart';
import 'package:perna/widgets/addButton.dart';
import 'package:perna/widgets/addHeader.dart';
import 'package:perna/widgets/formContainer.dart';
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
  final Future<IdTokenResult> Function() getRefreshToken;

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
    driverService: this.driverService, 
    clear: this.clear, 
    agent: this.agent, 
    accept: this.accept, 
    readOnly: this.readOnly, 
    getRefreshToken: this.getRefreshToken, 
    deny: this.deny
  );
}

class _ExpedientState extends State<ExpedientPage> {
  final Agent agent;
  final bool readOnly;
  final Function() accept;
  final Function() deny;
  final Function() clear;
  final _formKey = GlobalKey<FormState>();
  final Future<IdTokenResult> Function() getRefreshToken;
  final DriverService driverService;
  final DateFormat format = DateFormat('hh:mm dd/MM/yyyy');
  String name;
  String email;
  String places;
  String askedEndAt;
  String askedStartAt;
  bool isLoading = false;

  _ExpedientState({
    @required this.driverService, 
    @required this.readOnly, 
    @required this.agent, 
    @required this.clear, 
    this.getRefreshToken, 
    this.accept, 
    this.deny
  });

  void _askNewAgend(agent) async {
    int statusCode = await driverService.askNewAgent(agent);
    if(statusCode == 200){
      this.clear();
      Navigator.pop(context);
      showSnackBar(AppLocalizations.of(context).translate("successful_work_order"), 
        Colors.greenAccent, isGlobal: true);
    } else {
      setState(() { isLoading = false; });
      showSnackBar(AppLocalizations.of(context).translate("unsuccessful_work_order"), 
        Colors.redAccent, context: context);
    }
  }

  void _onPressed(String email, String fromEmail) async {
    if(_formKey.currentState.validate()){
      setState(() { isLoading = true; });
      Agent agent = this.agent.copyWith(
        email: email,
        name: this.name,
        askedEndAt: format.parse(askedEndAt),
        askedStartAt: format.parse(askedStartAt),
        fromEmail: fromEmail != email ? fromEmail : null,
        places: int.parse(this.places)
      );
      if(fromEmail != email) {
        this._askNewAgend(agent);
      } else {
        IdTokenResult idTokenResult = await this.getRefreshToken();
        int statusCode = await driverService.postNewAgent(agent, idTokenResult.token);
        if(statusCode==200){
          this.clear();
          Navigator.pop(context);
          showSnackBar( AppLocalizations.of(context).translate("successfully_added_expedient"), 
            Colors.greenAccent, isGlobal: true);
        }else{
          setState(() { isLoading = false; });
          showSnackBar(AppLocalizations.of(context).translate("unsuccessfully_added_expedient"), 
            Colors.redAccent, context: context);
        }
      }
    }
  }

  void _acceptOrDenny(accept){
    setState(() { isLoading=true; });
    (accept? this.accept(): this.deny()).then((_){ setState(() { isLoading=false; }); });
  }
  
  void _onSelectedExpedientOptions(Firestore firestore, ExpedientOptions result) async {
    setState(() { this.isLoading = true; });
    String email = result == ExpedientOptions.aboutDriver ? this.agent.email : this.agent.fromEmail;
    QuerySnapshot querySnapshot = await firestore.collection("user").where("email", isEqualTo:email).getDocuments();
    if(querySnapshot.documents.isNotEmpty){
      User user = User.fromJson(querySnapshot.documents.first.data);
      await Navigator.push(context, 
        MaterialPageRoute(
          builder: (context) => UserProfilePage(user: user)
        )
      );
    } else {
      showSnackBar(AppLocalizations.of(context).translate("not_found_user"), 
        Colors.redAccent, context: context
      );
    }
    setState(() {
      this.isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) => Material(
    child: isLoading ? Center(
      child:Loading(indicator: BallPulseIndicator(), size: 100.0, color: Theme.of(context).primaryColor)
    ) : StoreConnector<StoreState, Map<String, dynamic>>(
      converter: (store) => {
        "email": store.state.user.email,
        "firestore": store.state.firestore          
      },
      builder: (context, resources) => FormContainer(
        formkey: this._formKey,
        children: <Widget>[
          AddHeader(
            icon: Icons.work,
            name: AppLocalizations.of(context).translate("expedient"),
            readOnly: this.readOnly,
            showMenu: this.readOnly,
            child: PopupMenuButton(
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
            )
          ),
          SizedBox(height: 26),
          OutlinedTextFormField(
            readOnly: this.readOnly,
            initialValue: this.agent.name ?? "",
            onChanged: (text){ this.name = text; },
            labelText: AppLocalizations.of(context).translate("expedient_name"),
            icon: Icons.short_text,
            textInputAction: TextInputAction.next,
            validatorMessage: AppLocalizations.of(context).translate("enter_expedient_name"),
            onFieldSubmitted: (text){ FocusScope.of(context).nextFocus(); },
          ),
          SizedBox(height: 26),
          OutlinedTextFormField(
            readOnly: this.readOnly,
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
          FormTimePicker(
            initialValue: this.agent.askedStartAt,
            onChanged: (text){ this.askedStartAt = text; },
            action: TextInputAction.next,
            labelText: AppLocalizations.of(context).translate("expedient_start"),
            icon: Icons.insert_invitation,
            readOnly: this.readOnly,
            onSubmit: (text){ FocusScope.of(context).nextFocus(); },
            validatorMessage: AppLocalizations.of(context).translate("enter_start_expedient"),
          ),
          SizedBox(height: 26),
          FormTimePicker(
            initialValue: this.agent.askedEndAt,
            icon: Icons.insert_invitation,
            labelText: AppLocalizations.of(context).translate("expedient_end"),
            onChanged: (text){ this.askedEndAt = text; },
            readOnly: this.readOnly,
            validatorMessage: AppLocalizations.of(context).translate("enter_end_expedient"),
            onSubmit: (text){ FocusScope.of(context).nextFocus(); }
          ),
          SizedBox(height: 26),
          OutlinedTextFormField(
            readOnly: this.readOnly,
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
        ] + ( this.accept != null && this.deny != null && this.readOnly ? [
          ActionButtons(
            accept: (){ _acceptOrDenny(true); },
            deny: (){ _acceptOrDenny(false); }
          )
        ] : [
          AddButton(
            onPressed: () => this._onPressed(this.email, resources['email']),
            readOnly: this.readOnly,
          ),
        ])
      )
    )
  );
}