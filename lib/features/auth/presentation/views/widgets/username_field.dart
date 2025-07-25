import 'package:dirver/core/sharedWidgets/custom_text.dart';
import 'package:flutter/material.dart';

class UsernameField extends StatelessWidget {
  final TextEditingController usernameController;
  const UsernameField({super.key,required this.usernameController});

  @override
  Widget build(BuildContext context) {
    return customText(
      context: context,
      type: TextInputType.name,
      label: 'Enter name',
      hint: 'name',
      prefix: Icons.person,
      controller: usernameController,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Please enter name';
        }
        return null;
      },
    );
  }
}