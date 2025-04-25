import 'package:dirver/features/auth/presentation/state_managment/auth_bloc.dart';
import 'package:dirver/features/auth/presentation/views/widgets/login_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});
  static const String routeName = '/login';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: BlocProvider(
          create: (context) => AuthBloc(),
          child: const LoginBody(),
        ),
      ),
    );
  }
}