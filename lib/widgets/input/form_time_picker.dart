import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

class FormTimePicker extends StatelessWidget {
  FormTimePicker(
      {required this.readOnly,
      required this.labelText,
      required this.icon,
      this.onChanged,
      this.selectedDay,
      this.initialValue,
      this.value,
      this.validatorMessage,
      this.onSubmit,
      this.minTime,
      this.lastDay = 1,
      this.isRequired = false,
      this.action = TextInputAction.next});

  final DateFormat format = DateFormat('HH:mm dd/MM/yyyy');
  final DateFormat formatDate = DateFormat('dd/MM/yyyy');
  final DateFormat formatHour = DateFormat('HH:mm');
  final DateTime? initialValue;
  final String labelText;
  final String? validatorMessage;
  final IconData icon;
  final bool readOnly;
  final bool isRequired;
  final Function(String)? onChanged;
  final Function(String)? onSubmit;
  final TextInputAction action;
  final DateTime? minTime;
  final String? value;
  final String? selectedDay;
  final int lastDay;

  String formatInitialDate() {
    final String fullInitialDateString = format.format(initialValue!);
    if (fullInitialDateString.contains(selectedDay!)) {
      return fullInitialDateString.split(' ').first;
    }
    return fullInitialDateString;
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
        child: TextFormField(
            controller: initialValue == null
                ? TextEditingController(text: value)
                : null,
            readOnly: true,
            onTap: () async {
              if (!readOnly) {
                final DateTime initialTime = minTime ?? DateTime.now();
                final DateTime currentTime = value != '' && value != null &&
                        selectedDay != null
                    ? format
                        .parse(value!.length > 5 ? value! : '$value $selectedDay')
                    : initialTime;
                final DateTime selectedDate =
                    await DatePicker.showDateTimePicker(context,
                        minTime: initialTime,
                        maxTime: initialTime.add(Duration(days: lastDay)),
                        theme: DatePickerTheme(
                            backgroundColor: Theme.of(context).backgroundColor,
                            doneStyle: TextStyle(
                                color: Theme.of(context).primaryColor),
                            cancelStyle: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyText1!
                                    .color),
                            itemStyle: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyText1!
                                    .color)),
                        currentTime: currentTime,
                        locale: LocaleType.pt);
                if (selectedDate != null && onChanged != null) {
                  if (selectedDate.day == currentTime.day &&
                      selectedDate.month == currentTime.month &&
                      selectedDate.year == currentTime.year) {
                    onChanged!(formatHour.format(selectedDate));
                  } else {
                    onChanged!(format.format(selectedDate));
                  }
                }
              }
            },
            initialValue: initialValue != null ? formatInitialDate() : null,
            keyboardType: TextInputType.datetime,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText:
                  initialValue == null && value == null || value == '' ? null : labelText,
              hintText: value == null || value == '' ? labelText : null,
              suffixIcon: Icon(icon),
            ),
            textInputAction: action,
            validator: (String? value) {
              if (isRequired) {
                if (value == null || value.isEmpty) {
                  return validatorMessage;
                }
                final DateTime dateTime = format
                    .parse(value.length > 5 ? value : '$value $selectedDay');
                if (dateTime.isBefore(minTime ?? DateTime.now())) {
                  return validatorMessage;
                }
              }
              return null;
            },
            onFieldSubmitted: onSubmit));
  }
}
