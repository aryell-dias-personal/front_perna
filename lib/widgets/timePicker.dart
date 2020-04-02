import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart' as Intl;
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';

class TimePicker extends StatelessWidget {
  final String labelText;
  final Function onSelectedTime;
  final DateTime firstDateTime;
  final DateTime lastdateTime;

  TimePicker({@required this.labelText, @required this.onSelectedTime, this.firstDateTime, this.lastdateTime});

  Future<DateTime> _pickTime(context, currentValue) async {
    DateTime firstDate = DateTime.now().add(Duration(days: 1));
    final date = await showDatePicker(
        context: context,
        firstDate: this.firstDateTime ?? firstDate,
        initialDate: currentValue ?? this.firstDateTime ?? firstDate,
        lastDate: this.lastdateTime?.add(
          Duration(days: 1)
        )?.isAfter(
          this.firstDateTime??DateTime.now()
        ) ?? false ? this.lastdateTime : DateTime(2100));
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(currentValue ?? this.firstDateTime ?? firstDate)
      );
      return DateTimeField.combine(date, time);
    } else {
      return currentValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DateTimeField(
      format: Intl.DateFormat("yyyy-MM-dd HH:mm"),
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: labelText,
      ),
      onShowPicker: _pickTime,
      onChanged: onSelectedTime
    );
  }

}