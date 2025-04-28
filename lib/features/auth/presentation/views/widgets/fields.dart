// import 'package:dirver/core/sharedWidgets/logo_widget.dart';
// import 'package:dirver/features/auth/presentation/views/widgets/login_button.dart';
// import 'package:dirver/features/auth/presentation/views/widgets/login_title.dart';
// import 'package:dirver/features/auth/presentation/views/widgets/phone_field.dart';
// import 'package:dirver/features/auth/presentation/views/widgets/username_field.dart';
// import 'package:flutter/material.dart';

// class Fields extends StatefulWidget {
//   const Fields({super.key});

//   @override
//   State<Fields> createState() => _FieldsState();
// }

// class _FieldsState extends State<Fields> {
//   TextEditingController phoneController = TextEditingController();

//   TextEditingController userNameController = TextEditingController();

//   GlobalKey<FormState> formKey = GlobalKey<FormState>();

//   bool isPasswordVisible = false;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(15),
//           child: SingleChildScrollView(
//             child: Form(
//               key: formKey,
//               autovalidateMode: AutovalidateMode.onUserInteraction,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const LogoWidget(),
//                   SizedBox(height: MediaQuery.of(context).size.height * 0.02),
//                   const LoginTitle(),
//                   SizedBox(height: MediaQuery.of(context).size.height * 0.02),
//                   UsernameField(usernameController: userNameController),
//                   SizedBox(height: MediaQuery.of(context).size.height * 0.04),
//                   PhoneField(phoneController: phoneController),
//                   SizedBox(height: MediaQuery.of(context).size.height * 0.37),
//                   LoginButton(
//                       userNameController: userNameController,
//                       phoneController: phoneController),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
