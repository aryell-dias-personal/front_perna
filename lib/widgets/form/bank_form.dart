import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:perna/helpers/app_localizations.dart';
import 'package:perna/models/bank_account.dart';
import 'package:perna/widgets/button/add_button.dart';
import 'package:perna/widgets/form/form_container.dart';
import 'package:perna/widgets/input/outlined_text_form_field.dart';

class BankForm extends StatefulWidget {
  @override
  _BankFormState createState() => _BankFormState();
}

class _BankFormState extends State<BankForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  BankAccount bankAccount;

  // TODO: modificar bankAccount quando alterar os campos (inclusive montar o routingNumber) e definir icones
  @override
  Widget build(BuildContext context) {
    return FormContainer(formkey: _formKey, children: <Widget>[
      // TODO: selector de tipos de empresa de um enum
      Expanded(
          child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        margin: const EdgeInsets.only(left: 5, top: 6, right: 16),
        child: OutlinedTextFormField(
            readOnly: true,
            labelText: AppLocalizations.of(context).translate('account_holder_type'),
            icon: Icons.ac_unit),
      )),
      Expanded(
          child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        margin: const EdgeInsets.only(left: 5, top: 6, right: 16),
        child: OutlinedTextFormField(
            readOnly: true,
            labelText: AppLocalizations.of(context).translate('account_holder_name'),
            icon: Icons.ac_unit),
      )),
      Row(
        children: <Widget>[
          // TODO: selector do pais de um enum
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              margin: const EdgeInsets.only(left: 16, top: 6, right: 5),
              child: OutlinedTextFormField(
                readOnly: true,
                labelText: AppLocalizations.of(context).translate('country'),
                icon: Icons.ac_unit),
            ),
          ),
          // TODO: seleção automática apartir do coutry e visse versa
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              margin: const EdgeInsets.only(left: 16, top: 6, right: 5),
              child: OutlinedTextFormField(
                readOnly: true,
                labelText: AppLocalizations.of(context).translate('currency'),
                icon: Icons.ac_unit),
            ),
          ),
        ],
      ),
      Row(
        children: <Widget>[
          // TODO: selector de banco de um enum
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              margin: const EdgeInsets.only(left: 16, top: 6, right: 5),
              child: OutlinedTextFormField(
                readOnly: true,
                labelText: AppLocalizations.of(context).translate('bank_code'),
                icon: Icons.ac_unit),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              margin: const EdgeInsets.only(left: 16, top: 6, right: 5),
              child: OutlinedTextFormField(
                readOnly: true,
                labelText: AppLocalizations.of(context).translate('branch_code'),
                icon: Icons.ac_unit),
            ),
          ),
        ],
      ),
      Expanded(
          child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        margin: const EdgeInsets.only(left: 5, top: 6, right: 16),
        child: OutlinedTextFormField(
            readOnly: true,
            labelText: AppLocalizations.of(context).translate('account_number'),
            icon: Icons.ac_unit),
      )),
      Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[AddButton(onPressed: () {}, addAndcontinue: true)])
    ]);
  }
}
