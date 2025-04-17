import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseSignUp {
  final _supabase = Supabase.instance.client;
  Future<String> signup(
      String email, String password, String phone, String name) async {
    try {
      await _supabase.auth.signUp(
          email: email, password: password, phone: phone, data: {'name': name});
      return 'true';
    } catch (e) {
      return e.toString();
    }
  }

//   Future<String> signUpWithGoogle() async {
//     try {
//       await _supabase.auth.signInWithProvider(Provider.google);
//       return 'true';
//     } catch (e) {
//       return e.toString();
//     }
//   }
// }
}
