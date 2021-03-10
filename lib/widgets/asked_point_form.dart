import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:perna/helpers/app_localizations.dart';
import 'package:perna/helpers/credit_card.dart';
import 'package:perna/models/asked_point.dart';
import 'package:perna/widgets/add_button.dart';
import 'package:perna/widgets/form_container.dart';
import 'package:perna/widgets/form_date_picker.dart';
import 'package:perna/widgets/form_time_picker.dart';
import 'package:perna/widgets/outlined_text_form_field.dart';
import 'package:intl/intl.dart';

class AskedPointForm extends StatefulWidget {
  const AskedPointForm(
      {this.readOnly, this.askedPoint, this.onAddPressed, this.email});

  final String email;
  final bool readOnly;
  final AskedPoint askedPoint;
  final void Function(GlobalKey<FormState> formKey,
      {String email,
      String askedEndAt,
      String askedStartAt,
      String date}) onAddPressed;

  @override
  _AskedPointFormState createState() => _AskedPointFormState();
}

class _AskedPointFormState extends State<AskedPointForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final DateFormat format = DateFormat('HH:mm dd/MM/yyyy');
  final DateFormat dateFormat = DateFormat('dd/MM/yyyy');

  AskedPoint askedPoint;
  DateTime initialDateTime = DateTime.now();
  DateTime now = DateTime.now();
  DateTime minTime;
  String date;
  String askedEndAt;
  String askedStartAt;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      askedPoint = widget.askedPoint;
    });
    initialDateTime = DateTime(
        initialDateTime.year, initialDateTime.month, initialDateTime.day + 1);
    minTime = initialDateTime;
    date = dateFormat.format(askedPoint.date ?? minTime);
  }

  void _updateMinTime(String text) {
    final DateTime nextMinTime = dateFormat.parse(text);
    String nextAskedEndAt = askedEndAt;
    if (askedEndAt != null && askedStartAt != null) {
      final String minTimeString = dateFormat.format(minTime);
      final String askedEndAtString =
          askedEndAt.length > 5 ? askedEndAt : '$askedEndAt $minTimeString';
      final DateTime askedEndAtTime = format.parse(askedEndAtString);
      final Duration shift = nextMinTime.difference(minTime);
      final DateTime nextAskedEndAtTime = askedEndAtTime.add(shift);
      nextAskedEndAt = format.format(nextAskedEndAtTime);
      if (RegExp(text).hasMatch(nextAskedEndAt)) {
        nextAskedEndAt = nextAskedEndAt.split(' ')[0];
      }
    }
    setState(() {
      date = text;
      minTime = nextMinTime;
      askedEndAt = nextAskedEndAt;
    });
  }

  void _updateStartAt(String nextStartAt) {
    String nextAskedEndAt = askedEndAt;
    if (askedEndAt != null && askedStartAt != null) {
      final String minTimeString = dateFormat.format(minTime);
      final DateTime oldAskedStartAt =
          format.parse('$askedStartAt $minTimeString');
      final DateTime newAskedStartAt =
          format.parse('$nextStartAt $minTimeString');
      final String askedEndAtString =
          askedEndAt.length > 5 ? askedEndAt : '$askedEndAt $minTimeString';
      final DateTime askedEndAtTime = format.parse(askedEndAtString);
      final Duration shift = newAskedStartAt.difference(oldAskedStartAt);
      final DateTime nextAskedEndAtTime = askedEndAtTime.add(shift);
      nextAskedEndAt = format.format(nextAskedEndAtTime);
      if (RegExp(minTimeString).hasMatch(nextAskedEndAt)) {
        nextAskedEndAt = nextAskedEndAt.split(' ')[0];
      }
    }
    setState(() {
      askedStartAt = nextStartAt;
      askedEndAt = nextAskedEndAt;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FormContainer(formkey: _formKey, children: <Widget>[
      Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
        FormDatePicker(
          value: date,
          isRequired: true,
          initialValue: askedPoint.date ?? initialDateTime,
          onChanged: _updateMinTime,
          labelText: AppLocalizations.of(context).translate('date'),
          icon: Icons.insert_invitation,
          readOnly: widget.readOnly,
          onSubmit: (String text) {
            FocusScope.of(context).nextFocus();
          },
          validatorMessage:
              AppLocalizations.of(context).translate('select_a_date'),
        ),
        const SizedBox(height: 26),
        if (askedPoint.askedStartAt != null || !widget.readOnly)
          const SizedBox(width: 10),
        if (askedPoint.askedStartAt != null || !widget.readOnly)
          FormTimePicker(
              value: askedStartAt,
              minTime: initialDateTime,
              initialValue: askedPoint?.date?.add(askedPoint.askedStartAt),
              icon: Icons.access_time,
              labelText:
                  AppLocalizations.of(context).translate('desired_start'),
              onChanged: (String text) {
                final List<String> chuncks = text.split(' ');
                String minTimeString = dateFormat.format(initialDateTime);
                if (chuncks.length == 2) {
                  minTimeString = chuncks[1];
                }
                _updateStartAt(chuncks[0]);
                _updateMinTime(minTimeString);
              },
              selectedDay: date,
              lastDay: 31,
              readOnly: widget.readOnly,
              validatorMessage:
                  AppLocalizations.of(context).translate('enter_desired_start'),
              onSubmit: (String text) {
                FocusScope.of(context).nextFocus();
              })
      ]),
      const SizedBox(height: 26),
      if (askedPoint.askedEndAt != null || !widget.readOnly)
        FormTimePicker(
          value: askedEndAt,
          minTime: minTime,
          initialValue: askedPoint?.date?.add(askedPoint.askedEndAt),
          onChanged: (String text) {
            final String minTimeString = dateFormat.format(minTime);
            setState(() {
              if (RegExp(minTimeString).hasMatch(text)) {
                askedEndAt = text.split(' ')[0];
              } else {
                askedEndAt = text;
              }
            });
          },
          action: TextInputAction.done,
          selectedDay: date,
          labelText: AppLocalizations.of(context).translate('desired_end'),
          icon: Icons.access_time,
          readOnly: widget.readOnly,
          onSubmit: (String text) => widget.onAddPressed(
            _formKey,
            email: widget.email,
            askedEndAt: askedEndAt,
            askedStartAt: askedStartAt,
            date: date,
          ),
          validatorMessage:
              AppLocalizations.of(context).translate('enter_desired_end'),
        ),
      if (askedPoint.askedEndAt != null || !widget.readOnly)
        const SizedBox(height: 26),
      if (askedPoint.actualStartAt != null)
        FormTimePicker(
            readOnly: true,
            selectedDay: date,
            initialValue: askedPoint.actualStartAt,
            labelText: AppLocalizations.of(context).translate('actual_start'),
            icon: Icons.access_time),
      if (askedPoint.actualStartAt != null) const SizedBox(height: 26),
      if (askedPoint.actualEndAt != null)
        FormTimePicker(
            readOnly: true,
            selectedDay: date,
            initialValue: askedPoint.actualEndAt,
            labelText: AppLocalizations.of(context).translate('actual_end'),
            icon: Icons.access_time),
      if (askedPoint.actualEndAt != null) const SizedBox(height: 26),
      OutlinedTextFormField(
          readOnly: true,
          initialValue: askedPoint.friendlyOrigin,
          labelText: AppLocalizations.of(context).translate('start_place'),
          icon: Icons.pin_drop),
      const SizedBox(height: 26),
      OutlinedTextFormField(
          readOnly: true,
          initialValue: askedPoint.friendlyDestiny,
          labelText: AppLocalizations.of(context).translate('end_place'),
          icon: Icons.flag),
      const SizedBox(height: 26),
      if (askedPoint.amount != null)
        OutlinedTextFormField(
            readOnly: true,
            initialValue: formatAmount(askedPoint.amount, askedPoint.currency,
                AppLocalizations.of(context).locale),
            labelText: AppLocalizations.of(context).translate('price'),
            icon: Icons.payments_outlined),
      if (askedPoint.amount != null) const SizedBox(height: 26),
      AddButton(
          onPressed: () => widget.onAddPressed(
                _formKey,
                email: widget.email,
                askedEndAt: askedEndAt,
                askedStartAt: askedStartAt,
                date: date,
              ),
          readOnly: widget.readOnly,
          addAndcontinue: true)
    ]);
  }
}
