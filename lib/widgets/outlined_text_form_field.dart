import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OutlinedTextFormField extends StatelessWidget {
  const OutlinedTextFormField(
      {this.textInputAction,
      this.readOnly,
      this.initialValue,
      this.onChanged,
      this.labelText,
      this.validatorMessage,
      this.onFieldSubmitted,
      this.icon,
      this.textInputType});

  final bool readOnly;
  final String initialValue;
  final Function(String) onChanged;
  final String labelText;
  final String validatorMessage;
  final Function(String) onFieldSubmitted;
  final IconData icon;
  final TextInputAction textInputAction;
  final TextInputType textInputType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: textInputType,
      readOnly: readOnly,
      initialValue: initialValue,
      onChanged: onChanged,
      decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: labelText,
          suffixIcon: Icon(icon)),
      textInputAction: textInputAction,
      validator: (String value) => value.isNotEmpty ? null : validatorMessage,
      onFieldSubmitted: onFieldSubmitted,
    );
  }
}
