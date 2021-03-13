import 'dart:typed_data';
import 'package:perna/services/static_map.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:perna/main.dart';
import 'package:perna/services/driver.dart';
import 'package:perna/services/sign_in.dart';
import 'package:perna/widgets/form/expedient_form.dart';
import 'package:redux/redux.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:perna/helpers/app_localizations.dart';
import 'package:perna/helpers/show_snack_bar.dart';
import 'package:perna/models/agent.dart';
import 'package:perna/models/user.dart';
import 'package:perna/pages/user_profile_page.dart';
import 'package:perna/store/state.dart';
import 'package:intl/intl.dart';

enum ExpedientOptions { aboutDriver, aboutRequester }

class ExpedientPage extends StatefulWidget {
  const ExpedientPage(
      {required this.readOnly,
      required this.agent,
      required this.clear,
      this.accept,
      this.deny});

  final Agent agent;
  final bool readOnly;
  final Function()? deny;
  final Function() clear;
  final Function()? accept;

  @override
  _ExpedientState createState() => _ExpedientState();
}

class _ExpedientState extends State<ExpedientPage> {
  @override
  void initState() {
    super.initState();
    setState(() {
      agent = widget.agent;
    });
    if (agent.staticMap == null) {
      getIt<StaticMapService>()
          .getUint8List(markerA: agent.garage)
          .then((Uint8List uint8List) {
        setState(() {
          agent = agent.copyWith(staticMap: uint8List);
        });
      });
    }
  }

  final DateFormat format = DateFormat('HH:mm dd/MM/yyyy');
  final DateFormat dateFormat = DateFormat('dd/MM/yyyy');

  late Agent agent;
  bool isLoading = false;

  Future<void> _askNewAgend(Agent agent) async {
    final int statusCode = await getIt<DriverService>().askNewAgent(agent);
    if (statusCode == 200) {
      widget.clear();
      Navigator.pop(context);
      showSnackBar(
          AppLocalizations.of(context).translate('successful_work_order'),
          Colors.greenAccent,
          context);
    } else {
      setState(() {
        isLoading = false;
      });
      showSnackBar(
          AppLocalizations.of(context).translate('unsuccessful_work_order'),
          Colors.redAccent,
          context);
    }
  }

  Future<void> _onPressed(GlobalKey<FormState> formKey,
      {String? askedEndAt, String? askedStartAt, String? date, String? email, String? fromEmail, String? places}) async {
    if (formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      final DateTime dateTime = dateFormat.parse(date!);
      final String askedEndAtString =
          askedEndAt!.length > 5 ? askedEndAt : '$askedEndAt $date';
      final DateTime askedEndAtTime = format.parse(askedEndAtString);
      final DateTime askedStartAtTime = format.parse('$askedStartAt $date');
      final Agent agent = this.agent.copyWith(
          email: email,
          date: dateTime,
          askedStartAt: askedStartAtTime.difference(dateTime),
          askedEndAt: askedEndAtTime.difference(dateTime),
          fromEmail: fromEmail != email ? fromEmail : null,
          places: int.parse(places!));
      if (fromEmail != email) {
        _askNewAgend(agent);
      } else {
        final String? token = await getIt<SignInService>().getRefreshToken();
        final int statusCode = token == null ? 500 :
            await getIt<DriverService>().postNewAgent(agent, token);
        if (statusCode == 200) {
          widget.clear();
          Navigator.pop(context);
          showSnackBar(
              AppLocalizations.of(context)
                  .translate('successfully_added_expedient'),
              Colors.greenAccent,
              context);
        } else {
          setState(() {
            isLoading = false;
          });
          showSnackBar(
              AppLocalizations.of(context)
                  .translate('unsuccessfully_added_expedient'),
              Colors.redAccent,
              context);
        }
      }
    }
  }

  void _acceptOrDenny(bool accept) {
    setState(() {
      isLoading = true;
    });
    (accept ? widget.accept!() : widget.deny!()).then((_) {
      setState(() {
        isLoading = false;
      });
    });
  }

  Future<void> _onSelectedExpedientOptions(ExpedientOptions result) async {
    setState(() {
      isLoading = true;
    });
    final String email =
        result == ExpedientOptions.aboutDriver ? agent.email! : agent.fromEmail!;
    final QuerySnapshot querySnapshot = await getIt<FirebaseFirestore>()
        .collection('user')
        .where('email', isEqualTo: email)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      final User user = User.fromJson(querySnapshot.docs.first.data()!);
      await Navigator.push(
          context,
          MaterialPageRoute<UserProfilePage>(
              builder: (BuildContext context) => UserProfilePage(user: user)));
    } else {
      showSnackBar(AppLocalizations.of(context).translate('not_found_user'),
          Colors.redAccent, context);
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<StoreState, Map<String, dynamic>>(
        converter: (Store<StoreState> store) =>
            <String, dynamic>{'email': store.state.user!.email},
        builder: (BuildContext context, Map<String, dynamic> resources) =>
            Scaffold(
              appBar: AppBar(
                brightness: Theme.of(context).brightness,
                centerTitle: true,
                title: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                  Text(AppLocalizations.of(context).translate('expedient'),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 30.0)),
                  const SizedBox(width: 5),
                  const Icon(Icons.work, size: 30),
                ]),
                backgroundColor: Theme.of(context).backgroundColor,
                iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
                textTheme: TextTheme(
                    headline6: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 20,
                        fontFamily:
                            Theme.of(context).textTheme.headline6!.fontFamily)),
                actions: widget.readOnly
                    ? <Widget>[
                        PopupMenuButton<ExpedientOptions>(
                          tooltip: AppLocalizations.of(context)
                              .translate('open_menu'),
                          onSelected: (ExpedientOptions result) =>
                              _onSelectedExpedientOptions(result),
                          itemBuilder: (BuildContext context) =>
                              <PopupMenuEntry<ExpedientOptions>>[
                            PopupMenuItem<ExpedientOptions>(
                                value: ExpedientOptions.aboutDriver,
                                child: Text(AppLocalizations.of(context)
                                    .translate('about_driver'))),
                            if (agent.fromEmail != null)
                              PopupMenuItem<ExpedientOptions>(
                                  value: ExpedientOptions.aboutRequester,
                                  child: Text(AppLocalizations.of(context)
                                      .translate('about_requester')))
                          ],
                          offset: const Offset(0, 30),
                        )
                      ]
                    : null,
              ),
              body: Material(
                  child: isLoading
                      ? Center(
                          child: SpinKitDoubleBounce(
                              size: 100.0,
                              color: Theme.of(context).primaryColor))
                      : SingleChildScrollView(
                          child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                              SizedBox(
                                  height: 180,
                                  width: 600,
                                  child: Stack(
                                    children: <Widget>[
                                      Center(
                                          child: SpinKitDoubleBounce(
                                              size: 100.0,
                                              color: Theme.of(context)
                                                  .primaryColor)),
                                      if (agent.staticMap != null)
                                        Image.memory(agent.staticMap!)
                                    ],
                                  )),
                              ExpedientForm(
                                acceptPressed: () => _acceptOrDenny(true),
                                denyPressed: () => _acceptOrDenny(false),
                                agent: agent,
                                onAddPressed: _onPressed,
                                readOnly: widget.readOnly,
                                fromEmail: resources['email'] as String,
                                showActionButtons: widget.accept != null &&
                                    widget.deny != null &&
                                    widget.readOnly,
                              )
                            ]))),
            ));
  }
}
