import 'package:dirver/core/services/sharedPref/store_user_type.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider with ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;

  Future<UserCredential?> signInWithGoogle() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        throw Exception("Google sign-in was cancelled");
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final email = userCredential.user?.email;
      if (email == null) {
        throw Exception("Email not retrieved");
      }

      await StoreUserType.saveUserEmail(email);

      isLoading = false;
      notifyListeners();
      return userCredential;
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }
}
