import 'package:dirver/core/themes/styles.dart';
import 'package:dirver/features/auth/presentation/views/login_view.dart';
import 'package:flutter/material.dart';

class LoginRow extends StatelessWidget {
  const LoginRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Already have an account?'
        ,style: TextStyle(fontWeight: FontWeight.w500,fontSize: 15),),
        TextButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, LoginView.routeName);
          },
          child: Text('Login here',
          style: Styles.textSytle15),
        ),
      ],
    );
  }
}