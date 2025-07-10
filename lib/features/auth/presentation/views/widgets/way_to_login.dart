import 'package:flutter/material.dart';

class WayToLogin extends StatelessWidget {
  final String text;
  final Color colorButton;
  final Color colorText;
  final VoidCallback onPressed;
  const WayToLogin({super.key, required this.text, required this.colorButton,required this.colorText, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: colorButton,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 2,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: colorText,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
