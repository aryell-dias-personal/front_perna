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
  CompanyForm({this.company, this.readOnly = false, this.onSubmmitCompany}) {
    if (!readOnly) assert(onSubmmitCompany != null);
  }

  final void Function(Company, BankAccount) onSubmmitCompany;
  final Company company;
  final bool readOnly;

  @override
  _CompanyFormState createState() => _CompanyFormState();
}

class _CompanyFormState extends State<CompanyForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  FocusNode companyNameFocus = FocusNode();
  FocusNode structureFocus = FocusNode();
  Company company;

  @override
  void initState() {
    super.initState();
    setState(() {
      company = widget.company ?? Company();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FormContainer(formkey: _formKey, children: <Widget>[
      AutoCompleteField(
          readOnly: widget.readOnly,
          isRequired: true,
          initialValue: widget.company?.businessType,
          onFieldSubmitted: (String value) {
            structureFocus.requestFocus();
            company = company.copyWith(businessType: value);
          },
          onChanged: (String value) {
            company = company.copyWith(businessType: value);
          },
          textInputAction: TextInputAction.next,
          options: <String>[
            AppLocalizations.of(context).translate('individual'),
            AppLocalizations.of(context).translate('company'),
            AppLocalizations.of(context).translate('non_profit'),
            AppLocalizations.of(context).translate('government_entity')
          ],
          labelText: AppLocalizations.of(context).translate('business_type'),
          validatorMessage:
              AppLocalizations.of(context).translate('business_type_error'),
          icon: Icons.business_center),
      const SizedBox(height: 26),
      AutoCompleteField(
          readOnly: widget.readOnly,
          isRequired: true,
          initialValue: widget.company?.structure,
          onChanged: (String value) {
            company = company.copyWith(structure: value);
          },
          onFieldSubmitted: (String value) {
            companyNameFocus.requestFocus();
            company = company.copyWith(structure: value);
          },
          focusNode: structureFocus,
          textInputAction: TextInputAction.next,
          options: <String>[
              AppLocalizations.of(context).translate('government_instrumentality'),
              AppLocalizations.of(context).translate('governmental_unit'),
              AppLocalizations.of(context).translate('incorporated_non_profit'),
              AppLocalizations.of(context).translate('limited_liability_partnership'),
              AppLocalizations.of(context).translate('multi_member_llc'),
              AppLocalizations.of(context).translate('private_company'),
              AppLocalizations.of(context).translate('private_corporatio')
          ],
          labelText: AppLocalizations.of(context).translate('structure'),
          validatorMessage:
              AppLocalizations.of(context).translate('structure_error'),
          icon: Icons.assignment_rounded),
      const SizedBox(height: 26),
      OutlinedTextFormField(
          readOnly: widget.readOnly,
          initialValue: widget.company?.companyName,
          isRequired: true,
          textInputAction: TextInputAction.next,
          focusNode: companyNameFocus,
          onChanged: (String value) {
            company = company.copyWith(companyName: value);
          },
          labelText: AppLocalizations.of(context).translate('company_name'),
          validatorMessage:
              AppLocalizations.of(context).translate('company_name_error'),
          icon: Icons.short_text),
      const SizedBox(height: 26),
      OutlinedTextFormField(
          readOnly: widget.readOnly,
          initialValue: widget.company?.companyNumber,
          isRequired: true,
          textInputAction: TextInputAction.next,
          textInputType: TextInputType.number,
          onChanged: (String value) {
            company = company.copyWith(companyNumber: value);
          },
          labelText: AppLocalizations.of(context).translate('company_number'),
          validatorMessage:
              AppLocalizations.of(context).translate('company_number_error'),
          icon: Icons.business),
      const SizedBox(height: 26),
      OutlinedTextFormField(
          readOnly: widget.readOnly,
          initialValue: widget.company?.phone,
          isRequired: true,
          textInputAction: TextInputAction.next,
          textInputType: TextInputType.number,
          onChanged: (String value) {
            company = company.copyWith(phone: value);
          },
          labelText: AppLocalizations.of(context).translate('phone'),
          validatorMessage:
              AppLocalizations.of(context).translate('phone_error'),
          icon: Icons.contact_phone),
      const SizedBox(height: 26),
      OutlinedTextFormField(
          readOnly: widget.readOnly,
          initialValue: widget.company?.address,
          isRequired: true,
          onChanged: (String value) {
            company = company.copyWith(address: value);
          },
          labelText: AppLocalizations.of(context).translate('address'),
          validatorMessage:
              AppLocalizations.of(context).translate('address_error'),
          icon: Icons.markunread_mailbox_rounded),
      if (widget.readOnly) ...<Widget>[
        const SizedBox(height: 26),
        OutlinedTextFormField(
            readOnly: true,
            initialValue: widget.company?.manager,
            labelText: AppLocalizations.of(context).translate('manager_email'),
            icon: Icons.admin_panel_settings),
      ],
      const SizedBox(height: 26),
      Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
        AddButton(
          addAndcontinue: widget.readOnly,
          readOnly: widget.readOnly,
          onPressed: () {
            final bool valide = _formKey.currentState.validate();
            if (valide) {
              Navigator.push(
                  context,
                  MaterialPageRoute<BankPage>(
                      builder: (BuildContext context) => BankPage(
                            onSubmmitBankAccount: (BankAccount bankAccount) {
                              company = company.copyWith(
                                  country: bankAccount.countryCode,
                                  currency: bankAccount.currency);
                              widget.onSubmmitCompany(company, bankAccount);
                            },
                          )));
            }
          },
        )
      ])
    ]);
  }
}
