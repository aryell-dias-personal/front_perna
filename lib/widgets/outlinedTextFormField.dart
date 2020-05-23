import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OutlinedTextFormField extends StatelessWidget {
  final bool readOnly;
  final String initialValue;
  final Function onChanged;
  final String labelText;
  final String validatorMessage;
  final Function onFieldSubmitted;
  final IconData icon;
  final TextInputAction textInputAction;
  final TextInputType textInputType;

  const OutlinedTextFormField({
    this.textInputAction,
    this.readOnly, 
    this.initialValue, 
    this.onChanged, 
    this.labelText, 
    this.validatorMessage, 
    this.onFieldSubmitted, 
    this.icon, this.textInputType
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: textInputType,
      readOnly: this.readOnly,
      initialValue: this.initialValue,
      onChanged: this.onChanged,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: this.labelText,
        suffixIcon: Icon(this.icon)
      ),
      textInputAction: textInputAction,
      validator: (value) => value.isNotEmpty ? null : this.validatorMessage,
      onFieldSubmitted: this.onFieldSubmitted,
    );
  }
}