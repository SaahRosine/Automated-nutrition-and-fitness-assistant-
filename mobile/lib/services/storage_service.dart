import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _tokenKey = 'auth_token';

  /// Saves the authentication token to local storage.
  static Future<void> saveToken(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  /// Retrieves the authentication token from local storage.
  /// Returns null if no token is found.
  static Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Removes the authentication token from local storage.
  static Future<void> removeToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  /// Checks if an authentication token exists.
  static Future<bool> hasToken() async {
    final String? token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
