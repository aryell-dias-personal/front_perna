import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:perna/helpers/app_localizations.dart';
import 'package:perna/models/company.dart';
import 'package:perna/pages/bank_page.dart';
import 'package:perna/widgets/button/add_button.dart';
import 'package:perna/widgets/form/form_container.dart';
import 'package:perna/widgets/input/outlined_text_form_field.dart';

class CompanyForm extends StatefulWidget {
  const CompanyForm({this.readOnly = false});

  final bool readOnly;

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
      OutlinedTextFormField(
          readOnly: true,
          labelText: AppLocalizations.of(context).translate('business_type'),
          icon: Icons.business_center),
      const SizedBox(height: 26),
      OutlinedTextFormField(
          readOnly: true,
          labelText: AppLocalizations.of(context).translate('company_name'),
          icon: Icons.short_text),
      const SizedBox(height: 26),
      OutlinedTextFormField(
          readOnly: true,
          labelText: AppLocalizations.of(context).translate('manager'),
          icon: Icons.admin_panel_settings),
      const SizedBox(height: 26),
      OutlinedTextFormField(
          readOnly: true,
          labelText: AppLocalizations.of(context).translate('company_number'),
          icon: Icons.business),
      const SizedBox(height: 26),
      OutlinedTextFormField(
          readOnly: true,
          labelText: AppLocalizations.of(context).translate('phone'),
          icon: Icons.contact_phone),
      const SizedBox(height: 26),
      OutlinedTextFormField(
          readOnly: true,
          labelText: AppLocalizations.of(context).translate('address'),
          icon: Icons.markunread_mailbox_rounded),
      const SizedBox(height: 26),
      // TODO: enum para seleção de estrutura da empresa
      OutlinedTextFormField(
          readOnly: true,
          labelText: AppLocalizations.of(context).translate('structure'),
          icon: Icons.assignment_rounded),
      const SizedBox(height: 26),
      Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
        AddButton(
          addAndcontinue: true,
          readOnly: widget.readOnly,
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute<BankPage>(
                    builder: (BuildContext context) => BankPage()));
          },
        )
      ])
    ]);
  }
}
