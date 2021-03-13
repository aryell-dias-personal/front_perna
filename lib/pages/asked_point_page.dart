import 'dart:typed_data';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:perna/main.dart';
import 'package:perna/services/payments.dart';
import 'package:perna/services/sign_in.dart';
import 'package:perna/services/static_map.dart';
import 'package:perna/services/user.dart';
import 'package:perna/widgets/form/asked_point_form.dart';
import 'package:redux/redux.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:perna/helpers/app_localizations.dart';
import 'package:perna/helpers/show_snack_bar.dart';
import 'package:perna/models/agent.dart';
import 'package:perna/models/asked_point.dart';
import 'package:perna/models/credit_card.dart';
import 'package:perna/pages/asked_point_confirmation_page.dart';
import 'package:perna/pages/expedient_page.dart';
import 'package:perna/store/state.dart';
import 'package:intl/intl.dart';

enum AskedPointOptions { aboutExpedient }

class AskedPointPage extends StatefulWidget {
  const AskedPointPage(
      {@required this.readOnly,
      @required this.askedPoint,
      @required this.clear});

  final bool readOnly;
  final Function() clear;
  final AskedPoint askedPoint;

  @override
  _AskedPointPageState createState() => _AskedPointPageState();
}

class _AskedPointPageState extends State<AskedPointPage> {
  @override
  void initState() {
    super.initState();
    setState(() {
      askedPoint = widget.askedPoint;
    });
    if (askedPoint.staticMap == null) {
      getIt<StaticMapService>().getUint8List(
          markerA: askedPoint.origin,
          markerB: askedPoint.destiny,
          route: <LatLng>[
            askedPoint.origin,
            askedPoint.destiny
          ]).then((Uint8List uint8List) {
        setState(() {
          askedPoint = askedPoint.copyWith(staticMap: uint8List);
        });
      });
    }
  }

  final DateFormat format = DateFormat('HH:mm dd/MM/yyyy');
  final DateFormat dateFormat = DateFormat('dd/MM/yyyy');

  AskedPoint askedPoint;
  DateTime now = DateTime.now();
  bool isLoading = false;

  Future<void> _onPressed(GlobalKey<FormState> formKey,
      {String email,
      String askedEndAt,
      String askedStartAt,
      String date}) async {
    if (formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });
      final String token = await getIt<SignInService>().getRefreshToken();
      final List<CreditCard> creditCards =
          await getIt<PaymentsService>().listCard(token);
      if (creditCards.isEmpty) {
        setState(() {
          isLoading = false;
        });
        showSnackBar(
            AppLocalizations.of(context).translate('at_least_one_credit_card'),
            Colors.redAccent,
            context);
        return;
      }
      final DateTime dateTime = dateFormat.parse(date);
      DateTime askedEndAtTime, askedStartAtTime;
      if (askedEndAt != null) {
        final String askedEndAtString =
            askedEndAt.length > 5 ? askedEndAt : '$askedEndAt $date';
        askedEndAtTime = format.parse(askedEndAtString);
      }
      if (askedStartAt != null) {
        askedStartAtTime = format.parse('$askedStartAt $date');
      }
      final AskedPoint newAskedPoint = askedPoint.copyWith(
        email: email,
        date: dateTime,
        askedEndAt: askedEndAtTime?.difference(dateTime),
        askedStartAt: askedStartAtTime?.difference(dateTime),
      );
      final AskedPoint simulatedAskedPoint =
          await getIt<UserService>().simulateAskedPoint(newAskedPoint, token);

      if (simulatedAskedPoint != null) {
        await Navigator.push(
            context,
            MaterialPageRoute<AskedPointConfirmationPage>(
                builder: (BuildContext context) => AskedPointConfirmationPage(
                    askedPoint: simulatedAskedPoint,
                    userToken: token,
                    defaultCreditCard: creditCards.first,
                    clear: widget.clear)));
        setState(() {
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        showSnackBar(
            AppLocalizations.of(context)
                .translate('unsuccessfully_simutale_order'),
            Colors.redAccent,
            context);
      }
    }
  }

  Future<void> _onSelectedAskedPointOptions(AskedPointOptions result) async {
    setState(() {
      isLoading = true;
    });
    final DocumentSnapshot documentSnapshot = await getIt<FirebaseFirestore>()
        .collection('agent')
        .doc(askedPoint.agentId)
        .get();
    if (documentSnapshot.data().isNotEmpty) {
      final Agent agent = Agent.fromJson(documentSnapshot.data());
      await Navigator.push(
          context,
          MaterialPageRoute<ExpedientPage>(
              builder: (BuildContext context) =>
                  ExpedientPage(agent: agent, readOnly: true, clear: () {})));
    } else {
      showSnackBar(
          AppLocalizations.of(context).translate('not_found_expedient'),
          Colors.redAccent,
          context);
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) => StoreConnector<StoreState,
          Map<String, dynamic>>(
      converter: (Store<StoreState> store) => <String, dynamic>{
            'email': store.state.user.email,
          },
      builder: (BuildContext context, Map<String, dynamic> resources) =>
          Scaffold(
              appBar: AppBar(
                brightness: Theme.of(context).brightness,
                centerTitle: true,
                title: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                  Text(AppLocalizations.of(context).translate('order'),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 30.0)),
                  const SizedBox(width: 5),
                  const Icon(Icons.scatter_plot, size: 30),
                ]),
                backgroundColor: Theme.of(context).backgroundColor,
                iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
                textTheme: TextTheme(
                    headline6: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 20,
                        fontFamily:
                            Theme.of(context).textTheme.headline6.fontFamily)),
                actions: widget.readOnly && askedPoint.agentId != null
                    ? <Widget>[
                        PopupMenuButton<AskedPointOptions>(
                          tooltip: AppLocalizations.of(context)
                              .translate('open_menu'),
                          onSelected: (AskedPointOptions result) =>
                              _onSelectedAskedPointOptions(result),
                          itemBuilder: (BuildContext context) =>
                              <PopupMenuEntry<AskedPointOptions>>[
                            PopupMenuItem<AskedPointOptions>(
                                value: AskedPointOptions.aboutExpedient,
                                child: Text(AppLocalizations.of(context)
                                    .translate('about_expedient')))
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
                                        if (askedPoint.staticMap != null)
                                          Image.memory(askedPoint.staticMap)
                                      ],
                                    )),
                                AskedPointForm(
                                  readOnly: widget.readOnly,
                                  askedPoint: askedPoint,
                                  email: resources['email'] as String,
                                  onAddPressed: _onPressed,
                                )
                              ]),
                        ))));
}
