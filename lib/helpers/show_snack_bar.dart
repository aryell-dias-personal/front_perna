import 'package:flutter/material.dart';

void showSnackBar(String text, Color backgroundColor, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: backgroundColor,
      duration: const Duration(seconds: 3),
      content: Text(
        text,
        style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      )));
}
