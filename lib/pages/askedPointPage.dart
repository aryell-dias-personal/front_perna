import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:loading/loading.dart';
import 'package:perna/helpers/appLocalizations.dart';
import 'package:perna/models/agent.dart';
import 'package:perna/models/askedPoint.dart';
import 'package:perna/pages/expedientPage.dart';
import 'package:perna/services/user.dart';
import 'package:perna/store/state.dart';
import 'package:intl/intl.dart';
import 'package:perna/widgets/addButton.dart';
import 'package:perna/widgets/addHeader.dart';
import 'package:perna/widgets/formContainer.dart';
import 'package:perna/widgets/formTimePicker.dart';
import 'package:perna/widgets/outlinedTextFormField.dart';
import 'package:toast/toast.dart';

enum AskedPointOptions { aboutExpedient }

class AskedPointPage extends StatefulWidget {
  final bool readOnly;
  final Function() clear;
  final AskedPoint askedPoint;
  final Future<IdTokenResult> Function() getRefreshToken;

  const AskedPointPage({
    @required this.clear, 
    @required this.readOnly, 
    @required this.askedPoint, 
    this.getRefreshToken
  });

  @override
  _AskedPointPageState createState() => _AskedPointPageState(
    clear: this.clear, 
    readOnly: this.readOnly, 
    askedPoint: this.askedPoint, 
    getRefreshToken: this.getRefreshToken
  );
}

class _AskedPointPageState extends State<AskedPointPage> {
  final bool readOnly;
  final Function() clear;
  final AskedPoint askedPoint;
  final _formKey = GlobalKey<FormState>();
  final UserService userService = new UserService();
  final Future<IdTokenResult> Function() getRefreshToken;
  final DateFormat format = DateFormat('hh:mm dd/MM/yyyy');

  String name;
  String askedEndAt;
  String askedStartAt;
  bool isLoading = false;

  _AskedPointPageState({
    @required this.readOnly, 
    @required this.askedPoint, 
    @required this.clear, 
    this.getRefreshToken
  });

  void _onPressed(String email) async {
    if(_formKey.currentState.validate()){
      setState(() { isLoading = true; });
      IdTokenResult idTokenResult = await this.getRefreshToken();
      AskedPoint newAskedPoint =  this.askedPoint.copyWith(
        email: email,
        name: this.name,
        askedEndAt: format.parse(askedEndAt),
        askedStartAt: format.parse(askedStartAt)
      );
      int statusCode = await userService.postNewAskedPoint(newAskedPoint, idTokenResult.token);
      if(statusCode==200){
        Navigator.pop(context);
        this.clear();
        Toast.show(AppLocalizations.of(context).translate("successfully_added_order"), context, 
          backgroundColor: Colors.greenAccent, duration: 3);
      }else{
        setState(() { isLoading = false; });
        Toast.show(AppLocalizations.of(context).translate("unsuccessfully_added_order"), context, 
          backgroundColor: Colors.redAccent, duration: 3);
      }
    }
  }

  void _onSelectedAskedPointOptions(Firestore firestore, AskedPointOptions result) async {
    setState(() { this.isLoading = true; });
    DocumentSnapshot documentSnapshot = await firestore.collection("agent").document(this.askedPoint.agentId).get();
    if (documentSnapshot.data.isNotEmpty) {
      Agent agent = Agent.fromJson(documentSnapshot.data);
      await Navigator.push(context, MaterialPageRoute(
        builder: (context) => ExpedientPage(agent: agent, readOnly: true, clear: (){})
      ));
    } else {
      Toast.show(AppLocalizations.of(context).translate("not_found_expedient"), context, 
        backgroundColor: Colors.redAccent, duration: 3);
    }
    setState(() { this.isLoading = false; });
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
            name: AppLocalizations.of(context).translate("order"),
            readOnly: this.readOnly,
            icon: Icons.scatter_plot,
            showMenu: this.readOnly && this.askedPoint.agentId != null,
            child: PopupMenuButton(
              tooltip: AppLocalizations.of(context).translate("open_menu"),
              onSelected: (AskedPointOptions result) => this._onSelectedAskedPointOptions(resources["firestore"], result),
              itemBuilder:  (BuildContext context) => <PopupMenuEntry<AskedPointOptions>>[
                PopupMenuItem<AskedPointOptions>(
                  value: AskedPointOptions.aboutExpedient,
                  child: Text(AppLocalizations.of(context).translate("about_expedient"))
                )
              ]
            )
          ),
          SizedBox(height: 26),
          OutlinedTextFormField(
            readOnly: this.readOnly,
            initialValue: this.askedPoint.name ?? "",
            onChanged: (text){ this.name = text; },
            textInputAction: TextInputAction.next,
            labelText: AppLocalizations.of(context).translate("order_name"),
            icon: Icons.short_text,
            validatorMessage: AppLocalizations.of(context).translate("enter_order_name"),
            onFieldSubmitted: (text) { FocusScope.of(context).nextFocus(); },
          ),
          SizedBox(height: 26),
          FormTimePicker(
            initialValue: this.askedPoint.askedStartAt,
            icon: Icons.insert_invitation,
            labelText: AppLocalizations.of(context).translate("desired_start"),
            onChanged: (text){ this.askedStartAt = text; },
            readOnly: this.readOnly,
            validatorMessage: AppLocalizations.of(context).translate("enter_desired_start"),
            onSubmit: (text) { FocusScope.of(context).nextFocus(); }
          ),
          SizedBox(height: 26),
          FormTimePicker(
            initialValue: this.askedPoint.askedEndAt,
            onChanged: (text){ this.askedEndAt= text; },
            action: TextInputAction.done,
            labelText: AppLocalizations.of(context).translate("desired_end"),
            icon: Icons.insert_invitation,
            readOnly: this.readOnly,
            onSubmit: (text) => _onPressed(resources["email"]),
            validatorMessage: AppLocalizations.of(context).translate("enter_desired_end"),
          ),
          SizedBox(height: 26)
        ] + (this.askedPoint.actualStartAt!=null && this.askedPoint.actualEndAt!=null ? [
          FormTimePicker(
            readOnly: true,
            initialValue: this.askedPoint.actualStartAt,
            labelText: AppLocalizations.of(context).translate("actual_start"),
            icon: Icons.insert_invitation
          ),
          SizedBox(height: 26),
          FormTimePicker(
            readOnly: true,
            initialValue: this.askedPoint.actualEndAt,
            labelText: AppLocalizations.of(context).translate("actual_end"),
            icon: Icons.insert_invitation
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
          AddButton(
            onPressed: ()=>_onPressed(resources["email"]),
            readOnly: this.readOnly
          )
        ]
      )
    )
  );
}