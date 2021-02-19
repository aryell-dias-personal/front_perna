import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

class FormTimePicker extends StatelessWidget {
  final DateFormat format = DateFormat('HH:mm dd/MM/yyyy');
  final DateFormat formatDate = DateFormat('dd/MM/yyyy');
  final DateFormat formatHour = DateFormat('HH:mm');
  final DateTime initialValue;
  final String labelText;
  final String validatorMessage;
  final IconData icon;
  final bool readOnly;
  final bool isRequired;
  final Function(String) onChanged;
  final Function(String) onSubmit;
  final TextInputAction action;
  final DateTime minTime;
  final String value;
  final String selectedDay;
  final int lastDay;

  FormTimePicker({ 
    @required this.initialValue, 
    @required this.readOnly, 
    @required this.labelText, 
    @required this.icon,
    this.selectedDay,
    this.value,
    this.onChanged, 
    this.validatorMessage, 
    this.onSubmit, 
    this.minTime, 
    this.lastDay = 1,
    this.isRequired = false, 
    this.action = TextInputAction.next
  });

  String formatInitialDate() {
    String fullInitialDateString = this.format.format(this.initialValue);
    if(fullInitialDateString.contains(this.selectedDay)) {
      return fullInitialDateString.split(' ').first;
    }
    return fullInitialDateString;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: this.initialValue == null ? TextEditingController(
        text: value
      ): null,
      readOnly: true,
      onTap: () async {
        if(!this.readOnly) {
          DateTime initialTime = this.minTime ?? DateTime.now();
          DateTime currentTime = value != null && selectedDay !=null ? 
            format.parse(value.length > 5 ? value : "$value $selectedDay") : 
            initialTime;
          DateTime selectedDate = await DatePicker.showDateTimePicker(context,
            showTitleActions: true,
            minTime: initialTime,
            maxTime: initialTime.add(Duration(days: this.lastDay)),
            theme: DatePickerTheme(
              backgroundColor: Theme.of(context).backgroundColor,
              doneStyle: TextStyle(
                color: Theme.of(context).primaryColor
              ),
              cancelStyle: TextStyle(
                color: Theme.of(context).textTheme.bodyText1.color
              ),
              itemStyle: TextStyle(
                color: Theme.of(context).textTheme.bodyText1.color
              )
            ),
            currentTime: currentTime, 
            locale: LocaleType.pt
          );
          if(selectedDate != null) {
            if(selectedDate.day == currentTime.day 
              && selectedDate.month == currentTime.month 
              && selectedDate.year == currentTime.year) {
              this.onChanged(formatHour.format(selectedDate));
            } else {
              this.onChanged(format.format(selectedDate));
            }
          }
        }
      },
      initialValue: this.initialValue !=null? this.formatInitialDate() : null,
      keyboardType: TextInputType.datetime,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: this.initialValue == null && this.value == null ? null : this.labelText,
        hintText: this.value == null ? this.labelText : null,
        suffixIcon: Icon(icon),
      ), 
      textInputAction: action,
      validator: (value) {
        if (this.isRequired) {
          if(value.isEmpty) {
            return this.validatorMessage;
          }
          DateTime dateTime = format.parse(value.length > 5 ? value : "$value $selectedDay");
          if(!dateTime.isAfter(this.minTime ?? DateTime.now())) {
            return this.validatorMessage;
          }
        }
        return null;
      },
      onFieldSubmitted: this.onSubmit
    );
  }
}