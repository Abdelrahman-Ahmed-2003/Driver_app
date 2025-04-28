import 'package:flutter/material.dart';

abstract class AppColors {
  // Original Colors (Kept exactly as you defined them)
  static const Color primaryColor = Color(0XFF661AFD);  // Main brand purple
  static const Color grenColor = Color(0xFF25D366);     // Success green
  static const Color thirdColor = Color(0xFF075E54);    // Dark teal
  static const Color backgroundColor = Color(0xFFF2F2F2); // App background
  static const Color textColor = Color(0xFF000000);      // Primary text
  static const Color whiteColor = Color(0xFFFFFFFF);     // Pure white
  static const Color greyColor = Color(0xFFBDBDBD);      // Medium grey
  static const Color redColor = Color(0xFFFF0000);       // Error red
  static const Color blackColor = Color(0xFF000000);     // Pure black
  static const Color blueColor = Color(0xFF2196F3);      // Information blue
  static const Color yellowColor = Color(0xFFFFEB3B);    // Warning yellow
  static const Color orangeColor = Color(0xFFFF9800);    // Warning orange
  static const Color darkRed = Color.fromARGB(255, 131, 18, 18); // Darker red
  static const Color opalGrey = Color(0XFFC1CDCB);       // Light grey-green
  static const Color darkGrey = Color.fromRGBO(97, 97, 97, 1); // Dark grey

  // New Additions (Minimal necessary additions with clear purposes)
  static const Color dividerColor = Color(0xFFE0E0E0);   // For dividers (between greyColor and darkGrey)
  static const Color textHintColor = Color(0xFF9E9E9E);  // For hint/placeholder text
  static const Color mapOverlay = Color(0xAAFFFFFF);     // For map overlays (semi-transparent white)

  // Aliases for better semantic usage (pointing to your original colors)
  static const Color successColor = grenColor;          // For success states
  static const Color warningColor = orangeColor;        // For warning states
  static const Color errorColor = redColor;             // For error states
  static const Color infoColor = blueColor;             // For information states
  static const Color surfaceColor = whiteColor;         // For surfaces/cards
}