import 'package:flutter/material.dart';

Widget customText({
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
      style: TextStyle(
        fontSize: 14,
      ),
      onTap: onTap,
      enabled: enable,
      controller: controller,
      keyboardType: type,
      onChanged: onChanged,
      validator: validator,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelStyle: TextStyle(fontSize: 14),
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(
          prefix,
          size: 15,
        ),
        suffixIcon: IconButton(
          icon: Icon(suffix,size: 15,),
          onPressed: suffixPressed,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: const OutlineInputBorder(
          //borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(
            color: Color(0XFF661AFD),
            width: 2,
          ),
        ),
      ),
    );
