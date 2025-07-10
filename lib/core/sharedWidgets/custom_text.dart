import 'package:dirver/core/utils/colors_app.dart';
import 'package:flutter/material.dart';

Widget customText({
  required BuildContext context,
  TextEditingController? controller,
  required TextInputType type,
  Function(String)? onChanged,
  FormFieldValidator<String>? validator,
  String? label,
  String? hint,
  IconData? prefix,
  bool obscureText = false,
  IconData? suffix,
  Function()? suffixPressed,
  Function()? onTap,
  bool? enable,
}) =>
    TextFormField(
      style: const TextStyle(fontSize: 16),
      onTap: onTap,
      enabled: enable,
      controller: controller,
      keyboardType: type,
      onChanged: onChanged,
      validator: validator,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefix != null ? Icon(prefix, size: 20) : null,
        suffixIcon: suffix != null
            ? IconButton(icon: Icon(suffix, size: 20), onPressed: suffixPressed)
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
      ),
    );
