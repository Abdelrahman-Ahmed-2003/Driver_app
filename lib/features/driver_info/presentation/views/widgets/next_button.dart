
import 'package:dirver/core/utils/colors_app.dart';
import 'package:flutter/material.dart';

Widget buildNextButton(VoidCallback onPressed) {
  return Padding(
    padding: const EdgeInsets.only(left: 20, right: 20, bottom: 45),
    child: SizedBox(
      height: 50,
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: onPressed, // Calls the function passed from parent
    
        child: const Text(
          'Next',
          style: TextStyle(color: AppColors.whiteColor, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
    ),
  );
}
