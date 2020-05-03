import 'package:flutter/services.dart';

class TimeFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue){
    final int newTextLength = newValue.text.length;
    int selectionIndex = newValue.selection.end;
    final StringBuffer newText = StringBuffer();
    if(newTextLength < oldValue.text.length){
      newText.write(newValue.text.substring(0, newTextLength));
    } else if(newTextLength == 2 && !newValue.text.contains(":")) {
      newText.write(newValue.text.substring(0, 2)+":");
      selectionIndex++;
    } else if(newTextLength == 5 && !newValue.text.contains(" ")) {
      newText.write(newValue.text.substring(0, 5)+" ");
      selectionIndex++;
    } else if(newTextLength == 8) {
      newText.write(newValue.text.substring(0, 8)+"/");
      selectionIndex++;
    } else if(newTextLength == 11) {
      newText.write(newValue.text.substring(0, 11)+"/");
      selectionIndex++;
    } else if(newTextLength == 16) {
      newText.write(newValue.text.substring(0, 16));
    } else {
      newText.write(newValue.text.substring(0, newTextLength));
    }
    return TextEditingValue(
      text: newText.toString(),
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}