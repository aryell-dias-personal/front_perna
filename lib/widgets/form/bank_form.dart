import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:perna/constants/constants.dart';
import 'package:perna/helpers/app_localizations.dart';
import 'package:perna/models/bank_account.dart';
import 'package:perna/widgets/button/add_button.dart';
import 'package:perna/widgets/form/form_container.dart';
import 'package:perna/widgets/input/auto_complete_field.dart';
import 'package:perna/widgets/input/outlined_text_form_field.dart';

class BankForm extends StatefulWidget {
  BankForm(
      {this.bankAccount, this.readOnly = false, this.onSubmmitBankAccount}) {
    if (!readOnly) assert(onSubmmitBankAccount != null);
  }

  final void Function(BankAccount) onSubmmitBankAccount;
  final BankAccount bankAccount;
  final bool readOnly;

  @override
  _BankFormState createState() => _BankFormState();
}

class _BankFormState extends State<BankForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  BankAccount bankAccount;
  String bankCode = '';
  String branchCode = '';
  FocusNode accountHolderNameFocus = FocusNode();
  FocusNode countryFocus = FocusNode();
  FocusNode currencyFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    setState(() {
      bankAccount = widget.bankAccount ?? BankAccount();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FormContainer(formkey: _formKey, children: <Widget>[
      AutoCompleteField(
          readOnly: widget.readOnly,
          isRequired: true,
          validatorMessage: AppLocalizations.of(context)
              .translate('account_holder_type_error'),
          labelText:
              AppLocalizations.of(context).translate('account_holder_type'),
          textInputAction: TextInputAction.next,
          options: <String>[
            AppLocalizations.of(context).translate('individual'),
            AppLocalizations.of(context).translate('company'),
          ],
          onChanged: (String value) {
            bankAccount = bankAccount.copyWith(accountHolderType: value);
          },
          onFieldSubmitted: (String value) {
            accountHolderNameFocus.requestFocus();
            bankAccount = bankAccount.copyWith(accountHolderType: value);
          },
          icon: Icons.label_rounded),
      const SizedBox(height: 26),
      OutlinedTextFormField(
          readOnly: widget.readOnly,
          isRequired: true,
          validatorMessage: AppLocalizations.of(context)
              .translate('account_holder_name_error'),
          focusNode: accountHolderNameFocus,
          labelText:
              AppLocalizations.of(context).translate('account_holder_name'),
          textInputAction: TextInputAction.next,
          onChanged: (String value) {
            bankAccount = bankAccount.copyWith(accountHolderName: value);
          },
          icon: Icons.short_text),
      const SizedBox(height: 26),
      Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          AutoCompleteField(
              readOnly: widget.readOnly,
              isRequired: true,
              validatorMessage:
                  AppLocalizations.of(context).translate('country_error'),
              labelText: AppLocalizations.of(context).translate('country'),
              textInputAction: TextInputAction.next,
              onChanged: (String value) {
                bankAccount = bankAccount.copyWith(countryCode: value);
              },
              options: countries,
              onFieldSubmitted: (String value) {
                countryFocus.requestFocus();
                bankAccount = bankAccount.copyWith(countryCode: value);
              },
              icon: Icons.map_outlined),
          const SizedBox(width: 10),
          AutoCompleteField(
              readOnly: widget.readOnly,
              isRequired: true,
              validatorMessage:
                  AppLocalizations.of(context).translate('currency_error'),
              focusNode: countryFocus,
              labelText: AppLocalizations.of(context).translate('currency'),
              textInputAction: TextInputAction.next,
              onChanged: (String value) {
                bankAccount =
                    bankAccount.copyWith(currency: value.toLowerCase());
              },
              options: currencies,
              onFieldSubmitted: (String value) {
                currencyFocus.requestFocus();
                bankAccount =
                    bankAccount.copyWith(currency: value.toLowerCase());
              },
              icon: Icons.attach_money),
        ],
      ),
      const SizedBox(height: 26),
      Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          OutlinedTextFormField(
              readOnly: widget.readOnly,
              isRequired: true,
              textInputType: TextInputType.number,
              validatorMessage:
                  AppLocalizations.of(context).translate('bank_code_error'),
              focusNode: currencyFocus,
              textInputAction: TextInputAction.next,
              onChanged: (String value) {
                bankCode = value;
              },
              labelText: AppLocalizations.of(context).translate('bank_code')),
          const SizedBox(width: 10),
          OutlinedTextFormField(
              readOnly: widget.readOnly,
              textInputAction: TextInputAction.next,
              isRequired: true,
              textInputType: TextInputType.number,
              onChanged: (String value) {
                branchCode = value;
              },
              validatorMessage:
                  AppLocalizations.of(context).translate('branch_code_error'),
              labelText: AppLocalizations.of(context).translate('branch_code')),
        ],
      ),
      const SizedBox(height: 26),
      OutlinedTextFormField(
          readOnly: widget.readOnly,
          isRequired: true,
          textInputType: TextInputType.number,
          validatorMessage:
              AppLocalizations.of(context).translate('account_number_error'),
          textInputAction: TextInputAction.done,
          onChanged: (String value) {
            bankAccount = bankAccount.copyWith(accountNumber: value);
          },
          onFieldSubmitted: (String value) {
            final bool valide = _formKey.currentState.validate();
            if (valide) {
              widget.onSubmmitBankAccount(bankAccount);
            }
          },
          labelText: AppLocalizations.of(context).translate('account_number')),
      const SizedBox(height: 26),
      AddButton(
          readOnly: widget.readOnly,
          onPressed: () {
            final bool valide = _formKey.currentState.validate();
            if (valide) {
              bankAccount =
                  bankAccount.copyWith(routingNumber: '$bankCode-$branchCode');
              widget.onSubmmitBankAccount(bankAccount);
              Navigator.popUntil(context, (Route<dynamic> route) => route.isFirst);
            }
          })
    ]);
  }
}
