import 'package:dirver/core/utils/colors_app.dart';
import 'package:flutter/material.dart';
Widget buildTextField({required String label, required Function(String?) onSaved}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: AppColors.darkGrey,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          labelStyle: const TextStyle(color: AppColors.primaryColor),
        ),
        style: const TextStyle(color: AppColors.whiteColor),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'This field is required';
          }
          return null;
        },
        onSaved: onSaved,
      ),
    );
  }