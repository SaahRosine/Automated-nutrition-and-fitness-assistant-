import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Thin wrapper around [FlutterSecureStorage] for convenience.
///
/// All JWT tokens MUST be stored here — never in SharedPreferences.
/// This class is kept for backwards-compatibility with other parts of
/// the app that may already import it; internally it now delegates to
/// [FlutterSecureStorage] instead of SharedPreferences.
class StorageService {
  StorageService._();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const String _tokenKey = 'jwt_token';

  /// Saves the JWT to encrypted storage.
  static Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  /// Retrieves the JWT. Returns [null] if not found.
  static Future<String?> getToken() => _storage.read(key: _tokenKey);

  /// Removes the stored JWT (e.g. on logout).
  static Future<void> removeToken() => _storage.delete(key: _tokenKey);

  /// Returns [true] when a non-empty token exists in storage.
  static Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
