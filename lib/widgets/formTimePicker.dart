import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:perna/helpers/timeFormatter.dart';

class FormTimePicker extends StatelessWidget {
  final DateFormat format = DateFormat('kk:mm dd/MM/yyyy');
  final DateTime initialValue;
  final String labelText;
  final String validatorMessage;
  final IconData icon;
  final bool readOnly;
  final Function(String) onChanged;
  final Function(String) onSubmit;
  final TextInputAction action;

  FormTimePicker({Key key, 
    this.initialValue, this.readOnly, 
    this.onChanged, this.labelText, 
    this.validatorMessage, this.icon,
    this.onSubmit, this.action = TextInputAction.next
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: this.readOnly,
      initialValue: initialValue !=null? format.format(initialValue) : null,
      inputFormatters: <TextInputFormatter>[
        LengthLimitingTextInputFormatter(16),
        WhitelistingTextInputFormatter(RegExp(r"[0-9:/ ]")),
        TimeFormatter()
      ],
      onChanged: (text){
        this.onChanged(text);
      },
      keyboardType: TextInputType.datetime,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: this.labelText,
        hintText: "00:00 00/00/0000",
        suffixIcon: Icon(icon),
      ), 
      textInputAction: action,
      validator: (value) {
        if (value.isEmpty || value.length != 16) {
          return validatorMessage;
        }
        DateTime dateTime = format.parse(value);
        if(!dateTime.isAfter(DateTime.now())) {
          return validatorMessage;
        }
        return null;
      },
      onFieldSubmitted: this.onSubmit
    );
  }
}