import 'package:flutter/material.dart';

/*
this function displays an error message at the bottom of the screen
 */

void showNotifyMessage(BuildContext context, String errorMessage) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Center(
        child: Text(errorMessage, style: TextStyle(fontSize: 14),
        ),
      ),
      duration: const Duration(seconds: 1),
    ),
  );
}