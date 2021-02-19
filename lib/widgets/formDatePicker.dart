import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class FormDatePicker extends StatelessWidget {
  final DateFormat format = DateFormat('dd/MM/yyyy');
  final DateTime initialValue;
  final String labelText;
  final String validatorMessage;
  final IconData icon;
  final bool readOnly;
  final bool isRequired;
  final Function(String) onChanged;
  final Function(String) onSubmit;
  final TextInputAction action;
  final String value;

  FormDatePicker({ 
    @required this.icon,
    @required this.onSubmit,
    @required this.initialValue, 
    @required this.readOnly, 
    @required this.onChanged, 
    @required this.labelText, 
    @required this.validatorMessage, 
    @required this.value, 
    this.isRequired = false, 
    this.action = TextInputAction.next
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: TextEditingController(
        text: this.value ?? this.format.format(this.initialValue)
      ),
      readOnly: true,
      onTap: () async {
        if(!this.readOnly) {
          DateTime selectedDate = await showDatePicker(
            context: context, 
            initialDate: this.value != null ? this.format.parse(this.value) : this.initialValue, 
            firstDate: this.initialValue, 
            lastDate: this.initialValue.add(Duration(days: 31))
          );
          if(selectedDate != null) {
            String date = DateFormat('dd/MM/yyyy').format(selectedDate);
            this.onChanged(date);
          }
        }
      },
      keyboardType: TextInputType.datetime,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: this.labelText,
        suffixIcon: Icon(icon),
      ), 
      textInputAction: action,
      validator: (value) {
        if (this.isRequired) {
          if(value.isEmpty) {
            return this.validatorMessage;
          }
          DateTime dateTime = this.format.parse(value);
          if(this.initialValue.isAfter(dateTime)) {
            return this.validatorMessage;
          }
        }
        return null;
      },
      onFieldSubmitted: this.onSubmit
    );
  }
}