import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:perna/helpers/app_localizations.dart';

class AutoCompleteField extends StatefulWidget {
  const AutoCompleteField(
      {this.width,
      this.textInputAction,
      this.readOnly = false,
      this.options = const <String>[],
      this.initialValue,
      this.onChanged,
      this.labelText,
      this.validatorMessage,
      this.onFieldSubmitted,
      this.isRequired = false,
      this.icon,
      this.focusNode,
      this.textInputType});

  final List<String> options;
  final bool readOnly;
  final bool isRequired;
  final String initialValue;
  final Function(String) onChanged;
  final String labelText;
  final String validatorMessage;
  final Function(String) onFieldSubmitted;
  final IconData icon;
  final TextInputAction textInputAction;
  final TextInputType textInputType;
  final double width;
  final FocusNode focusNode;

  @override
  _AutoCompleteFieldState createState() => _AutoCompleteFieldState();
}

class _AutoCompleteFieldState extends State<AutoCompleteField> {
  final TextEditingController textEditingController = TextEditingController();
  String searchValue = '';
  bool typing = false;
  FocusNode focusNode;

  @override
  void initState() {
    super.initState();
    focusNode = widget.focusNode ?? FocusNode();
    focusNode.addListener(() {
      typing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: TypeAheadFormField<String>(
        initialValue: widget.initialValue,
        noItemsFoundBuilder: (BuildContext context) {
          return const SizedBox();
        },
        suggestionsBoxDecoration: SuggestionsBoxDecoration(
          clipBehavior: Clip.hardEdge,
          borderRadius: BorderRadius.circular(5),
        ),
        validator: (String value) {
          if (widget.isRequired) {
            if (value.isEmpty) {
              return widget.validatorMessage;
            }
            if (!widget.options.contains(value)) {
              return AppLocalizations.of(context)
                  .translate('auto_complete_error');
            }
          }
          return null;
        },
        textFieldConfiguration: TextFieldConfiguration(
          controller: textEditingController,
          focusNode: widget.focusNode,
          enabled: !widget.readOnly,
          keyboardType: widget.textInputType,
          onChanged: (String value) {
            typing = true;
            if (widget.onChanged == null) {
              widget.onChanged(value);
            }
          },
          textInputAction: widget.textInputAction,
          style: const TextStyle(fontSize: 16, fontFamily: 'ProductSans'),
          decoration: InputDecoration(
              disabledBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Theme.of(context).disabledColor)),
              border: const OutlineInputBorder(),
              labelText: widget.labelText,
              labelStyle:
                  const TextStyle(fontSize: 16, fontFamily: 'ProductSans'),
              suffixIcon: Icon(widget.icon)),
        ),
        suggestionsCallback: (String pattern) async {
          List<String> currOptions;
          if (typing) {
            currOptions = widget.options
                .where((String option) => RegExp(pattern.toLowerCase())
                    .hasMatch(option.toLowerCase()))
                .toList();
          } else {
            currOptions = widget.options;
          }
          return currOptions;
        },
        itemBuilder: (BuildContext context, String suggestion) {
          return ListTile(
            title: Text(suggestion),
          );
        },
        onSuggestionSelected: (String suggestion) {
          searchValue = suggestion;
          textEditingController.text = suggestion;
          if (widget.onFieldSubmitted != null) {
            widget.onFieldSubmitted(searchValue);
          }
        },
      ),
    );
  }
}
