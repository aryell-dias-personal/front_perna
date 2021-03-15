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
      OutlinedTextFormField(
          readOnly: true,
          labelText:
              AppLocalizations.of(context).translate('account_holder_type'),
          icon: Icons.ac_unit),
      const SizedBox(height: 26),
      OutlinedTextFormField(
          readOnly: true,
          labelText:
              AppLocalizations.of(context).translate('account_holder_name'),
          icon: Icons.short_text),
      const SizedBox(height: 26),
      Row(
        mainAxisSize: MainAxisSize.min, 
        children: <Widget>[
          // TODO: selector do pais de um enum
          OutlinedTextFormField(
              readOnly: true,
              labelText: AppLocalizations.of(context).translate('country'),
              icon: Icons.map_outlined),
          const SizedBox(width: 10),
          // TODO: seleção automática apartir do coutry e visse versa
          OutlinedTextFormField(
              readOnly: true,
              labelText: AppLocalizations.of(context).translate('currency'),
              icon: Icons.attach_money),
        ],
      ),
      const SizedBox(height: 26),
      Row(
        mainAxisSize: MainAxisSize.min, 
        children: <Widget>[
          // TODO: selector de banco de um enum
          OutlinedTextFormField(
              readOnly: true,
              labelText: AppLocalizations.of(context).translate('bank_code')),
          const SizedBox(width: 10),
          OutlinedTextFormField(
              readOnly: true,
              labelText: AppLocalizations.of(context).translate('branch_code')),
        ],
      ),
      const SizedBox(height: 26),
      OutlinedTextFormField(
          readOnly: true,
          labelText: AppLocalizations.of(context).translate('account_number')),
      const SizedBox(height: 26),
      AddButton(readOnly: false, onPressed: () {})
    ]);
  }
}
