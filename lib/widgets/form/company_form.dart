import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:perna/helpers/app_localizations.dart';
import 'package:perna/models/bank_account.dart';
import 'package:perna/models/company.dart';
import 'package:perna/pages/bank_page.dart';
import 'package:perna/widgets/button/add_button.dart';
import 'package:perna/widgets/form/form_container.dart';
import 'package:perna/widgets/input/auto_complete_field.dart';
import 'package:perna/widgets/input/outlined_text_form_field.dart';

class CompanyForm extends StatefulWidget {
  CompanyForm({this.bankAccount, this.readOnly = false, this.onSubmmitCompany}) {
    if (!readOnly) assert(onSubmmitCompany != null);
  }

  final Function(Company) onSubmmitCompany;
  final Company bankAccount;
  final bool readOnly;

  @override
  _CompanyFormState createState() => _CompanyFormState();
}

class _CompanyFormState extends State<CompanyForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  FocusNode companyNameFocus = FocusNode();
  Company company;

  @override
  Widget build(BuildContext context) {
    return FormContainer(formkey: _formKey, children: <Widget>[
      AutoCompleteField(  
          readOnly: widget.readOnly,
          isRequired: true,
          onFieldSubmitted: (String value) {
            companyNameFocus.requestFocus();
            company = company.copyWith(businessType: value);
          },
          labelText: AppLocalizations.of(context).translate('business_type'),
          icon: Icons.business_center),
      const SizedBox(height: 26),
      OutlinedTextFormField(
          readOnly: widget.readOnly,
          isRequired: true,
          focusNode: companyNameFocus,
          onFieldSubmitted: (String value) {
            company = company.copyWith(companyName: value);
          },
          labelText: AppLocalizations.of(context).translate('company_name'),
          icon: Icons.short_text),
      const SizedBox(height: 26),
      OutlinedTextFormField(
          readOnly: widget.readOnly,
          isRequired: true,
          onFieldSubmitted: (String value) {
            company = company.copyWith(manager: value);
          },
          labelText: AppLocalizations.of(context).translate('manager'),
          icon: Icons.admin_panel_settings),
      const SizedBox(height: 26),
      OutlinedTextFormField(
          readOnly: widget.readOnly,
          isRequired: true,
          textInputType: TextInputType.number,
          onFieldSubmitted: (String value) {
            company = company.copyWith(companyNumber: value);
          },
          labelText: AppLocalizations.of(context).translate('company_number'),
          icon: Icons.business),
      const SizedBox(height: 26),
      OutlinedTextFormField(
          readOnly: widget.readOnly,
          isRequired: true,
          textInputType: TextInputType.number,
          onFieldSubmitted: (String value) {
            company = company.copyWith(phone: value);
          },
          labelText: AppLocalizations.of(context).translate('phone'),
          icon: Icons.contact_phone),
      const SizedBox(height: 26),
      OutlinedTextFormField(
          readOnly: widget.readOnly,
          isRequired: true,
          onFieldSubmitted: (String value) {
            company = company.copyWith(address: value);
          },
          labelText: AppLocalizations.of(context).translate('address'),
          icon: Icons.markunread_mailbox_rounded),
      const SizedBox(height: 26),
      AutoCompleteField(
          readOnly: widget.readOnly,
          isRequired: true,
          onFieldSubmitted: (String value) {
            company = company.copyWith(structure: value);
            Navigator.push(
                context,
                MaterialPageRoute<BankPage>(
                    builder: (BuildContext context) => BankPage(
                      onSubmmitBankAccount: (BankAccount bankAccount) {
                        widget.onSubmmitCompany(company.copyWith(
                          bankAccount: bankAccount,
                        ));
                      },
                    )));
          },
          labelText: AppLocalizations.of(context).translate('structure'),
          icon: Icons.assignment_rounded),
      const SizedBox(height: 26),
      Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
        AddButton(
          addAndcontinue: widget.readOnly,
          readOnly: widget.readOnly,
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute<BankPage>(
                    builder: (BuildContext context) => BankPage(
                      onSubmmitBankAccount: (BankAccount bankAccount) {
                        widget.onSubmmitCompany(company.copyWith(
                          bankAccount: bankAccount,
                        ));
                      },
                    )));
          },
        )
      ])
    ]);
  }
}
