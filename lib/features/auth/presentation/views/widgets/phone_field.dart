import 'package:dirver/core/utils/colors_app.dart';
import 'package:flutter/material.dart';

class PhoneField extends StatelessWidget {
  final TextEditingController phoneController;
  const PhoneField({super.key, required this.phoneController});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: TextStyle(
        fontSize: 14,
      ),
      controller: phoneController,
      keyboardType: TextInputType.phone,
      validator: (value) {
        if (phoneController.text.isEmpty ||
            phoneController.text.length != 10 ||
            RegExp(r'\D').hasMatch(phoneController.text)) {
          return 'Please enter your phone number';
        }
        return null;
      },
      decoration: InputDecoration(
        
        labelStyle: TextStyle(fontSize: 14),
        labelText: 'Enter your Phone number',
        hintText: 'Your phone number',
        prefixIcon: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('+20',textAlign: TextAlign.center,),
          ],
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: const OutlineInputBorder(
          //borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(
            color: AppColors.primaryColor,
            width: 2,
          ),
        ),
      ),
    );
  }
}
