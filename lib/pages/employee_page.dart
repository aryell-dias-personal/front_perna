import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:perna/helpers/show_snack_bar.dart';
import 'package:perna/services/sign_in.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:perna/helpers/app_localizations.dart';
import 'package:perna/main.dart';
import 'package:perna/services/company.dart';
import 'package:perna/widgets/form/form_container.dart';
import 'package:perna/widgets/input/outlined_text_form_field.dart';

class AddEmployeePage extends StatefulWidget {
  const AddEmployeePage({@required this.companyId});

  final String companyId;

  @override
  _AddEmployeePageState createState() => _AddEmployeePageState();
}

class _AddEmployeePageState extends State<AddEmployeePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String email = '';
  bool isLoading = false;

  Future<void> answerManager(String companyId) async {
    if (_formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });
      final String token = await getIt<SignInService>().getRefreshToken();
      final int statusCode = await getIt<CompanyService>().askEmployee(companyId, email, token);
      if (statusCode == 200) {
        Navigator.pop(context);
        showSnackBar(
            AppLocalizations.of(context)
                .translate('successfully_requested_employee'),
            Colors.greenAccent,
            context);
      } else {
        setState(() {
          isLoading = false;
        });
        showSnackBar(
            AppLocalizations.of(context)
                .translate('unsuccessfully_requested_employee'),
            Colors.redAccent,
            context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Theme.of(context).brightness,
        centerTitle: true,
        title: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
          Text(AppLocalizations.of(context).translate('manage_employees'),
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 30.0)),
          const SizedBox(width: 5),
          const Icon(Icons.person_add_alt_1_outlined, size: 30),
        ]),
        backgroundColor: Theme.of(context).backgroundColor,
        iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
        textTheme: TextTheme(
            headline6: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 20,
                fontFamily: Theme.of(context).textTheme.headline6.fontFamily)),
      ),
      body: isLoading
        ? Center(
            child: SpinKitDoubleBounce(
                size: 100.0,
                color: Theme.of(context).primaryColor))
        : Material(
          child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                FormContainer(formkey: _formKey, children: <Widget>[
                  OutlinedTextFormField(
                    readOnly: false,
                    onChanged: (String text) {
                      email = text;
                    },
                    textInputType: TextInputType.emailAddress,
                    labelText: AppLocalizations.of(context).translate('driver_email'),
                    icon: Icons.email,
                    textInputAction: TextInputAction.done,
                    isRequired: true,
                    validatorMessage:
                        AppLocalizations.of(context).translate('enter_driver_email'),
                    onFieldSubmitted: (String text) async {
                      answerManager(widget.companyId);
                    },
                  ),
                  const SizedBox(height: 26),
                  ElevatedButton(
                    onPressed: () async {
                      answerManager(widget.companyId);
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Theme.of(context).primaryColor),
                      shape: MaterialStateProperty.all(const StadiumBorder()),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                      Text(
                          AppLocalizations.of(context)
                              .translate('request_employee'),
                          style: TextStyle(
                              color: Theme.of(context).backgroundColor, fontSize: 18)),
                      Icon(Icons.question_answer_outlined,
                          color: Theme.of(context).backgroundColor, size: 20)
                    ]),
                  )
                ]
                )
              ]
            ),
        )
      ),
    );
  }
}
