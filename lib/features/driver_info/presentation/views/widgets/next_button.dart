
import 'package:flutter/material.dart';

Widget buildNextButton(VoidCallback onPressed) {
  return SizedBox(
    height: 50,
    width: double.infinity,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0XFF661AFD),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: onPressed, // Calls the function passed from parent

      child: const Text(
        'Next',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
      ),
    ),
  );
}
