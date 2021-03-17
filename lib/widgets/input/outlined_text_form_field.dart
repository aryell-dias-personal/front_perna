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
      this.isRequired = false,
      this.onFieldSubmitted,
      this.icon,
      this.focusNode,
      this.textInputType});

  final bool readOnly;
  final FocusNode focusNode;
  final bool isRequired;
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
    return Flexible(
        child: TextFormField(
      focusNode: focusNode,
      keyboardType: textInputType,
      readOnly: readOnly,
      initialValue: initialValue,
      onChanged: onChanged,
      decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: labelText,
          suffixIcon: Icon(icon)),
      textInputAction: textInputAction,
      validator: (String value) {
        if (isRequired) {
          if (value.isEmpty) {
            return validatorMessage;
          }
        }
        return null;
      },
      onFieldSubmitted: onFieldSubmitted,
    ));
  }
}
