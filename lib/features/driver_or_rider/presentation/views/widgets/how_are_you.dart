import 'package:flutter/material.dart';

class HowAreYou extends StatelessWidget {
  final String text;
  final Color colorButton;
  final Color colorText;
  final VoidCallback onPressed;
  const HowAreYou({super.key, required this.text, required this.colorButton,required this.colorText, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: colorButton,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(color: colorText, fontSize: 20),
        ),
      ),
    );
  }
}