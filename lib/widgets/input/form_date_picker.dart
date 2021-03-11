import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class FormDatePicker extends StatelessWidget {
  FormDatePicker(
      {@required this.icon,
      @required this.onSubmit,
      @required this.initialValue,
      @required this.readOnly,
      @required this.onChanged,
      @required this.labelText,
      @required this.validatorMessage,
      @required this.value,
      this.isRequired = false,
      this.action = TextInputAction.next});

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

  @override
  Widget build(BuildContext context) {
    return Flexible(
        child: TextFormField(
            controller: TextEditingController(
                text: value ?? format.format(initialValue)),
            readOnly: true,
            onTap: () async {
              if (!readOnly) {
                final DateTime selectedDate = await showDatePicker(
                    context: context,
                    initialDate:
                        value != null ? format.parse(value) : initialValue,
                    firstDate: initialValue,
                    lastDate: initialValue.add(const Duration(days: 31)));
                if (selectedDate != null) {
                  final String date =
                      DateFormat('dd/MM/yyyy').format(selectedDate);
                  onChanged(date);
                }
              }
            },
            keyboardType: TextInputType.datetime,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: labelText,
              suffixIcon: Icon(icon),
            ),
            textInputAction: action,
            validator: (String value) {
              if (isRequired) {
                if (value.isEmpty) {
                  return validatorMessage;
                }
                final DateTime dateTime = format.parse(value);
                if (initialValue.isAfter(dateTime)) {
                  return validatorMessage;
                }
              }
              return null;
            },
            onFieldSubmitted: onSubmit));
  }
}
