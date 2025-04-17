import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseLogin {
  final _supabase = Supabase.instance.client;
  Future<String> login(
      String email, String password) async {
    try {
      final response = await _supabase.auth
          .signInWithPassword(email: email, password: password);
      if (response.user != null) {
        return 'true';
      } else {
        return 'false';
      }
    } catch (e) {
      return e.toString();
    }
  }
}
