import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:perna/helpers/app_localizations.dart';
import 'package:perna/pages/company_page.dart';
import 'package:perna/widgets/button/add_button.dart';
import 'package:perna/widgets/form/form_container.dart';
import 'package:perna/widgets/input/outlined_text_form_field.dart';

class CompanyForm extends StatefulWidget {
  @override
  _CompanyFormState createState() => _CompanyFormState();
}

class _CompanyFormState extends State<CompanyForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Company company;

  // TODO: modificar company quando alterar os campos e definir icones
  @override
  Widget build(BuildContext context) {
    return FormContainer(formkey: _formKey, children: <Widget>[
      // TODO: enum para seleção de estrutura da empresa
      Expanded(
          child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        margin: const EdgeInsets.only(left: 5, top: 6, right: 16),
        child: OutlinedTextFormField(
            readOnly: true,
            labelText: AppLocalizations.of(context).translate('business_type'),
            icon: Icons.ac_unit),
      )),
      Expanded(
          child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        margin: const EdgeInsets.only(left: 5, top: 6, right: 16),
        child: OutlinedTextFormField(
            readOnly: true,
            labelText: AppLocalizations.of(context).translate('company_name'),
            icon: Icons.ac_unit),
      )),
      Expanded(
          child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        margin: const EdgeInsets.only(left: 5, top: 6, right: 16),
        child: OutlinedTextFormField(
            readOnly: true,
            labelText: AppLocalizations.of(context).translate('manager'),
            icon: Icons.ac_unit),
      )),
      Expanded(
          child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        margin: const EdgeInsets.only(left: 5, top: 6, right: 16),
        child: OutlinedTextFormField(
            readOnly: true,
            labelText: AppLocalizations.of(context).translate('company_number'),
            icon: Icons.ac_unit),
      )),
      Expanded(
          child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        margin: const EdgeInsets.only(left: 5, top: 6, right: 16),
        child: OutlinedTextFormField(
            readOnly: true,
            labelText: AppLocalizations.of(context).translate('phone'),
            icon: Icons.ac_unit),
      )),
      Expanded(
          child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        margin: const EdgeInsets.only(left: 5, top: 6, right: 16),
        child: OutlinedTextFormField(
            readOnly: true,
            labelText: AppLocalizations.of(context).translate('address'),
            icon: Icons.ac_unit),
      )),
      // TODO: enum para seleção de estrutura da empresa
      Expanded(
          child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        margin: const EdgeInsets.only(left: 5, top: 6, right: 16),
        child: OutlinedTextFormField(
            readOnly: true,
            labelText: AppLocalizations.of(context).translate('structure'),
            icon: Icons.ac_unit),
      )),
      Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[AddButton(onPressed: () {})])
    ]);
  }
}
