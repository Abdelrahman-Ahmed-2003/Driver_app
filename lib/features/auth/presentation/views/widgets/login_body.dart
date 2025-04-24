import 'package:dirver/core/constant/asset_images.dart';
import 'package:dirver/core/services/sharedPref/store_user_type.dart';
import 'package:dirver/core/sharedWidgets/logo_widget.dart';
import 'package:dirver/core/utils/colors_app.dart';
import 'package:dirver/features/auth/presentation/views/widgets/way_to_login.dart';
import 'package:dirver/features/driver_or_rider/presentation/views/driver_or_rider.dart';
import 'package:dirver/features/splash_screen/presentation/views/widgets/text_in_splash.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginBody extends StatelessWidget {
  const LoginBody({super.key});

  /// **Sign in with Google & Handle Errors**
  Future<UserCredential?> signInWithGoogle(BuildContext context) async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        throw "Google sign-in was cancelled";
      }

      // Obtain auth details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );


      // Sign in with Firebase
      final UserCredential userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);

      // Get user details
      String? email = userCredential.user?.email;
      String? userId = userCredential.user?.uid;

      if (email == null || userId == null) {
        throw "Failed to retrieve user details.";
      }

      // Save user ID in SharedPreferences
      await StoreUserType.saveUserId(email??'');

      // Navigate to DriverOrRider Page
      Navigator.pushReplacementNamed(
        context,
        DriverOrRider.routeName,
      );

      return userCredential;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Sign-in failed: $e")),
      );
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          const LogoWidget(),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          Image.asset(AssetImages.handShake, height: 300),
          TextInSplash(text: 'Ease your Transportation with us'),
          const Spacer(),
          // WayToLogin(
          //   text: 'Phone number',
          //   colorButton: Colors.black,
          //   colorText: Colors.white,
          //   onPressed: () {
          //     Navigator.pushReplacementNamed(
          //       context,
          //       MaterialPageRoute(builder: (context) => const Fields()),
          //     );
          //   },
          // ),
          const SizedBox(height: 10),
          WayToLogin(
            text: "Google",
            colorButton: AppColors.primaryColor,
            colorText: AppColors.blackColor,
            onPressed: () async {
              await signInWithGoogle(context);
            },
          ),
        ],
      ),
    );
  }
}
