import 'package:dirver/features/auth/presentation/state_managment/auth_provider.dart';
import 'package:dirver/features/auth/presentation/views/widgets/login_body.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});
  static const String routeName = '/login';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: ChangeNotifierProvider(
          create: (context) => AuthProvider(),
          child: const LoginBody(),
        ),
      ),
    );
  }
}