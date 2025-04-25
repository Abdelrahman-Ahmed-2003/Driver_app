import 'package:bloc/bloc.dart';
import 'package:dirver/core/services/sharedPref/store_user_type.dart';
import 'package:dirver/features/auth/presentation/state_managment/auth_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';


class AuthBloc extends Cubit<AuthState>{
  AuthBloc() : super(AuthInitial());


  /// **Sign in with Google & Handle Errors**
  Future<UserCredential?> signInWithGoogle() async {
    try {
      emit(LoginLoading());
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
      await StoreUserType.saveUserEmail(email);

      
      emit(LoginSuccess());
      return userCredential;
    } catch (e) {
      emit(LoginFailure(errorMessage: e.toString()));
      return null;
    }
  }
}