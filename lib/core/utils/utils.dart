import 'package:flutter/material.dart';

void errorMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating, // <-- Important!!
      margin: const EdgeInsets.all(20), // <-- Add margin to not cover bottomNavigationBar
      content: Text(message),
      backgroundColor: Colors.red,
    ),
  );
}

