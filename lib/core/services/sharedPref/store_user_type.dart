import 'package:shared_preferences/shared_preferences.dart';

class StoreUserType {
  static const String _lastSignIn = "LASTSIGNIN"; // Stores last selected role
  static const String _userIdKey = "USER_ID"; // Stores last logged-in user
  static const String _driver = "DRIVER";
  static const String _passenger ='PASSENGER';

  /// Save if user signed in as passenger
  static Future<void> saveLastSignIn(String userType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSignIn, userType);
  }

  static Future<void> savePassenger(bool pass) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_passenger, pass);
  }

  static Future<bool?> getPassenger() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_passenger);
  }



  /// Save if user signed in as driver
  static Future<void> saveDriver(bool bol) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_driver, bol);
  }

  /// Get passenger
  static Future<String?> getLastSignIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastSignIn);
  }

  /// Get driver
  static Future<bool?> getDriver() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_driver);
  }

  /// Get last logged-in user ID
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  /// Get last logged-in user ID
  static Future<void> saveUserId(String email) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_userIdKey,email);
  }

  /// Remove user session (logout)
  static Future<void> clearUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastSignIn);
    await prefs.remove(_driver);
    await prefs.remove(_userIdKey);
  }
}
