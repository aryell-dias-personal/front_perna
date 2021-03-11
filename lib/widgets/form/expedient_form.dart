import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:perna/helpers/app_localizations.dart';
import 'package:perna/models/agent.dart';
import 'package:perna/widgets/button/action_buttons.dart';
import 'package:perna/widgets/button/add_button.dart';
import 'package:perna/widgets/form/form_container.dart';
import 'package:perna/widgets/input/form_date_picker.dart';
import 'package:perna/widgets/input/form_time_picker.dart';
import 'package:perna/widgets/input/outlined_text_form_field.dart';
import 'package:intl/intl.dart';

class ExpedientForm extends StatefulWidget {
  const ExpedientForm(
      {this.readOnly,
      this.showActionButtons,
      this.agent,
      this.onAddPressed,
      this.denyPressed,
      this.acceptPressed,
      this.fromEmail});

  final bool readOnly;
  final Agent agent;
  final bool showActionButtons;
  final String fromEmail;
  final void Function(GlobalKey<FormState> formKey,
      {String email,
      String fromEmail,
      String askedEndAt,
      String askedStartAt,
      String date,
      String places}) onAddPressed;
  final void Function() denyPressed;
  final void Function() acceptPressed;

  @override
  _ExpedientFormState createState() => _ExpedientFormState();
}

class _ExpedientFormState extends State<ExpedientForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final DateFormat format = DateFormat('HH:mm dd/MM/yyyy');
  final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
  DateTime initialDateTime = DateTime.now();
  DateTime minTime;
  String date;
  String email;
  String places;
  String askedEndAt;
  String askedStartAt;
  Agent agent;

  @override
  void initState() {
    super.initState();
    setState(() {
      agent = widget.agent;
    });
    initialDateTime = DateTime(
        initialDateTime.year, initialDateTime.month, initialDateTime.day + 1);
    minTime = initialDateTime;
    date = dateFormat.format(agent.date ?? minTime);
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
      OutlinedTextFormField(
        readOnly: widget.readOnly,
        initialValue: (agent.email ?? email) ?? '',
        onChanged: (String text) {
          email = text;
        },
        textInputType: TextInputType.emailAddress,
        labelText: AppLocalizations.of(context).translate('driver_email'),
        icon: Icons.email,
        textInputAction: TextInputAction.next,
        validatorMessage:
            AppLocalizations.of(context).translate('enter_driver_email'),
        onFieldSubmitted: (String text) {
          FocusScope.of(context).nextFocus();
        },
      ),
      if (agent.fromEmail != null) const SizedBox(height: 26),
      if (agent.fromEmail != null)
        OutlinedTextFormField(
            readOnly: true,
            initialValue: agent.fromEmail,
            textInputType: TextInputType.emailAddress,
            labelText:
                AppLocalizations.of(context).translate('requester_email'),
            icon: Icons.email),
      const SizedBox(height: 26),
      Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
        FormDatePicker(
          value: date,
          isRequired: true,
          initialValue: initialDateTime,
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
        const SizedBox(width: 10),
        FormTimePicker(
          isRequired: true,
          minTime: initialDateTime,
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
          value: askedStartAt,
          lastDay: 31,
          initialValue: agent?.date?.add(agent.askedStartAt),
          labelText: AppLocalizations.of(context).translate('expedient_start'),
          icon: Icons.access_time,
          readOnly: widget.readOnly,
          onSubmit: (String text) {
            FocusScope.of(context).nextFocus();
          },
          validatorMessage:
              AppLocalizations.of(context).translate('enter_start_expedient'),
        ),
      ]),
      const SizedBox(height: 26),
      FormTimePicker(
          isRequired: true,
          minTime: minTime,
          selectedDay: date,
          value: askedEndAt,
          initialValue: agent?.date?.add(agent.askedEndAt),
          icon: Icons.access_time,
          labelText: AppLocalizations.of(context).translate('expedient_end'),
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
          readOnly: widget.readOnly,
          validatorMessage:
              AppLocalizations.of(context).translate('enter_end_expedient'),
          onSubmit: (String text) {
            FocusScope.of(context).nextFocus();
          }),
      const SizedBox(height: 26),
      OutlinedTextFormField(
        readOnly: widget.readOnly,
        initialValue: (agent.places?.toString() ?? places?.toString()) ?? '',
        onChanged: (String text) {
          places = text;
        },
        textInputType: TextInputType.number,
        labelText: AppLocalizations.of(context).translate('seats_number'),
        icon: Icons.airline_seat_legroom_normal,
        textInputAction: TextInputAction.done,
        validatorMessage:
            AppLocalizations.of(context).translate('enter_seats_number'),
        onFieldSubmitted: (String text) => widget.onAddPressed(
          _formKey,
          email: email,
          fromEmail: widget.fromEmail,
          askedEndAt: askedEndAt,
          askedStartAt: askedStartAt,
          date: date,
          places: places,
        ),
      ),
      const SizedBox(height: 26),
      OutlinedTextFormField(
          readOnly: true,
          initialValue: agent.friendlyGarage,
          labelText: AppLocalizations.of(context).translate('garage'),
          icon: Icons.pin_drop),
      const SizedBox(height: 26),
      if (widget.showActionButtons)
        ActionButtons(accept: widget.acceptPressed, deny: widget.denyPressed),
      if (!widget.showActionButtons)
        AddButton(
          onPressed: () => widget.onAddPressed(
            _formKey,
            email: email,
            fromEmail: widget.fromEmail,
            askedEndAt: askedEndAt,
            askedStartAt: askedStartAt,
            date: date,
            places: places,
          ),
          readOnly: widget.readOnly,
        ),
    ]);
  }
}
