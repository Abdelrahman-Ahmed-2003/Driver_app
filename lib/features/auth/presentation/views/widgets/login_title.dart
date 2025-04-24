import 'package:dirver/core/utils/colors_app.dart';
import 'package:flutter/material.dart';

class LoginTitle extends StatelessWidget {
  const LoginTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Join with us through phone number',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,),
        Text('We will send a verification code via SMS',
            style: TextStyle(fontSize: 15, color: AppColors.greyColor),
            textAlign: TextAlign.center,),
      ],
    );
  }
}