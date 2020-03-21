import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';

class TimePicker extends StatelessWidget {
  final String labelText;

  TimePicker({@required this.labelText});

  Future<DateTime> _pickTime(context, currentValue) async {
    final date = await showDatePicker(
        context: context,
        firstDate: DateTime(1900),
        initialDate: currentValue ?? DateTime.now(),
        lastDate: DateTime(2100));
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
      );
      return DateTimeField.combine(date, time);
    } else {
      return currentValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DateTimeField(
      format: DateFormat("yyyy-MM-dd HH:mm"),
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: labelText,
      ),
      onShowPicker: _pickTime,
    );
  }

}