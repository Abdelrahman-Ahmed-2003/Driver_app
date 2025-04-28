// import 'package:dirver/core/sharedWidgets/custom_button.dart';
// import 'package:dirver/features/auth/presentation/views/widgets/otp_screen.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class LoginButton extends StatelessWidget {
//   final TextEditingController userNameController;
//   final TextEditingController phoneController;

//   const LoginButton(
//       {super.key,
//       required this.userNameController,
//       required this.phoneController});

//   @override
//   Widget build(BuildContext context) {
//     return CustomButton(
//         text: 'Send',
//         onPressed: () async {
//           String trimmedUserName = userNameController.text.trim();
//           String trimmedPhone = phoneController.text.trim();
//           if (trimmedUserName.isEmpty) {
//             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//               content: Text('Please enter a valid Gmail address'),
//               //backgroundColor: Colors.red,
//             ));
//           } else if (trimmedPhone.isEmpty || trimmedPhone.length != 10) {
//             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//               content: Text('Please enter your phone number'),
//               // backgroundColor: Colors.red,
//             ));
//           } else {
//             // FirebaseAuth auth = FirebaseAuth.instance;

//             String phone = phoneController.text.trim();

//             // Ensure phone number is exactly 11 digits (Egypt) after removing spaces
//             if (phone.length != 10) {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                     content:
//                         Text("Please enter a valid 11-digit phone number.")),
//               );
//               return;
//             }

//             // Append country code if not already present
//             String fullPhoneNumber = "+20$phone";

//             FirebaseAuth.instance.verifyPhoneNumber(
//               phoneNumber: fullPhoneNumber,
//               timeout: const Duration(seconds: 60),
//               verificationCompleted: (PhoneAuthCredential credential) async {
//                 await FirebaseAuth.instance.signInWithCredential(credential);
//               },
//               verificationFailed: (FirebaseAuthException e) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text("Error: ${e.message}")),
//                 );
//               },
//               codeSent: (String verificationId, int? resendToken) {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) =>
//                         OTPScreen(verificationId: verificationId),
//                   ),
//                 );
//               },
//               codeAutoRetrievalTimeout: (String verificationId) {},
//             );
//           }
//         });
//   }
// }
