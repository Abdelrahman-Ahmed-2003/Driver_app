import 'dart:io';
import 'package:dirver/features/auth/presentation/views/widgets/email_field.dart';
import 'package:dirver/features/auth/presentation/views/widgets/login_row.dart';
import 'package:dirver/features/auth/presentation/views/widgets/password_field.dart';
import 'package:dirver/features/auth/presentation/views/widgets/phone_field.dart';
import 'package:dirver/features/auth/presentation/views/widgets/signup_button.dart';
import 'package:dirver/features/auth/presentation/views/widgets/signup_title.dart';
import 'package:dirver/features/auth/presentation/views/widgets/username_field.dart';
import 'package:flutter/material.dart';

class SignupBody extends StatefulWidget {
  const SignupBody({super.key});

  @override
  State<SignupBody> createState() => _SignupBodyState();
}

class _SignupBodyState extends State<SignupBody> {
  TextEditingController emailController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  File? imageFile;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: SingleChildScrollView(
        child: Form(
          key: formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              
              const SignupTitle(),
              SizedBox(height: MediaQuery.of(context).size.height * 0.04),
              UsernameField(usernameController: usernameController),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              EmailField(emailController: emailController),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              PhoneField(phoneController: phoneController),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              PasswordField(
                  passwordController: passwordController,
                  toogleVisibility: () {
                    setState(() {
                      isPasswordVisible = !isPasswordVisible;
                    });
                  },
                  isPasswordVisible: isPasswordVisible),
              SizedBox(height: MediaQuery.of(context).size.height * 0.04),
              SignupButton(
                onScuccess: () async {
                  // NewUser user = NewUser(
                  //     emailController: emailController.text,
                  //     passwordController: passwordController.text,
                  //     usernameController: usernameController.text,
                  //     phoneController: phoneController.text,
                  //     imageFile: imageFile);
                  // String temp = await user.addNewUser();
                  // if (temp == 'ok') {
                  //   debugPrint('imaageeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee');
                  //   debugPrint(imageFile.toString());
                  //   temp = await user.sendVerefcation();
                  //   if (temp == 'ok' && await user.startVerificationCheck()) {
                  //     Navigator.pushReplacement(
                  //         context,
                  //         MaterialPageRoute(
                  //             builder: (context) => const HomeView()));
                  //   } else {
                  //     ScaffoldMessenger.of(context).showSnackBar(
                  //       SnackBar(
                  //         content: Text(temp),
                  //       ),
                  //     );
                  //   }
                  // } else {
                  //   ScaffoldMessenger.of(context).showSnackBar(
                  //     SnackBar(
                  //       content: Text(temp),
                  //     ),
                  //   );
                  // }
                },
                emailController: emailController,
                passwordController: passwordController,
                phoneController: phoneController,
                usernameController: usernameController,
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              const LoginRow(),
            ],
          ),
        ),
      ),
    );
  }
}
