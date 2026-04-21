import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile/core/constants/api_constants.dart';

/// Wraps an API call result into a discriminated union so callers never
/// need to catch exceptions themselves.
class AuthResult {
  final bool success;
  final String? token;
  final String? error;

  const AuthResult._({required this.success, this.token, this.error});

  factory AuthResult.ok(String token) =>
      AuthResult._(success: true, token: token);

  factory AuthResult.fail(String message) =>
      AuthResult._(success: false, error: message);
}

/// Single source of truth for all authentication HTTP calls.
///
/// The [_dio] instance is shared across the app via the [UserProvider].
/// Its request interceptor automatically attaches `Authorization: Bearer <token>`
/// on every outgoing request when a token is available in secure storage.
class AuthService {
  // ── Secure storage ────────────────────────────────────────────────────────
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  static const _tokenKey = 'jwt_token';

  // ── Dio client (lazy singleton) ───────────────────────────────────────────
  late final Dio _dio;

  AuthService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // ── Auth interceptor ──────────────────────────────────────────────────
    // Reads the stored JWT before every request and attaches it.
    // On 401 responses it clears the stale token automatically.
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            // Token was rejected by the server — wipe it locally.
            await deleteToken();
          }
          return handler.next(error);
        },
      ),
    );
  }

  // ── Token helpers ─────────────────────────────────────────────────────────

  Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  Future<String?> getToken() => _storage.read(key: _tokenKey);

  Future<void> deleteToken() => _storage.delete(key: _tokenKey);

  Future<bool> hasToken() async {
    final t = await getToken();
    return t != null && t.isNotEmpty;
  }

  // ── Auth calls ────────────────────────────────────────────────────────────

  /// Registers a new account. Returns [AuthResult] without a token (the
  /// user must then log in explicitly, matching the backend's design).
  Future<AuthResult> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.signUp,
        data: {'email': email, 'password': password},
      );

      if (response.data['success'] == true) {
        final token = response.data['token'] as String;
        await saveToken(token);
        return AuthResult.ok(token);
      }

      return AuthResult.fail(
        response.data['message'] ?? 'Sign-up failed.',
      );
    } on DioException catch (e) {
      return AuthResult.fail(_parseDioError(e));
    } catch (_) {
      return AuthResult.fail('An unexpected error occurred.');
    }
  }

  /// Authenticates an existing user. On success, persists the JWT in
  /// [FlutterSecureStorage] and returns it inside [AuthResult].
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );

      if (response.data['success'] == true) {
        final token = response.data['token'] as String;
        await saveToken(token);
        return AuthResult.ok(token);
      }

      return AuthResult.fail(
        response.data['message'] ?? 'Login failed. Please try again.',
      );
    } on DioException catch (e) {
      return AuthResult.fail(_parseDioError(e));
    } catch (_) {
      return AuthResult.fail('An unexpected error occurred.');
    }
  }

  /// Exchanges the current token for a fresh one (30-day session).
  /// Call this in the background on app resume to keep sessions alive.
  Future<AuthResult> rotateToken() async {
    try {
      // The interceptor will attach the current token automatically.
      final response = await _dio.post(ApiConstants.rotateToken);

      if (response.data['success'] == true) {
        final newToken = response.data['token'] as String;
        await saveToken(newToken);
        return AuthResult.ok(newToken);
      }

      return AuthResult.fail(
        response.data['message'] ?? 'Token rotation failed.',
      );
    } on DioException catch (e) {
      return AuthResult.fail(_parseDioError(e));
    } catch (_) {
      return AuthResult.fail('An unexpected error occurred.');
    }
  }

  /// Updates the user's email or password.
  /// Requires the current [email] and [password] for verification.
  Future<AuthResult> updateProfile({
    required String email,
    required String password,
    String? newEmail,
    String? newPassword,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.updateProfile,
        data: {
          'email': email,
          'password': password,
          if (newEmail != null) 'newEmail': newEmail,
          if (newPassword != null) 'newPassword': newPassword,
        },
      );

      if (response.data['success'] == true) {
        final token = response.data['token'] as String?;
        if (token != null) {
          await saveToken(token);
        }
        return AuthResult.ok(token ?? '');
      }

      return AuthResult.fail(
        response.data['message'] ?? 'Profile update failed.',
      );
    } on DioException catch (e) {
      return AuthResult.fail(_parseDioError(e));
    } catch (_) {
      return AuthResult.fail('An unexpected error occurred.');
    }
  }

  /// Permanently deletes the user's account.
  /// Requires the current [email] and [password] for verification.
  Future<AuthResult> deleteAccount({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.deleteAccount,
        data: {'email': email, 'password': password},
      );

      if (response.data['success'] == true) {
        await deleteToken();
        return AuthResult.ok('');
      }

      return AuthResult.fail(
        response.data['message'] ?? 'Account deletion failed.',
      );
    } on DioException catch (e) {
      return AuthResult.fail(_parseDioError(e));
    } catch (_) {
      return AuthResult.fail('An unexpected error occurred.');
    }
  }

  // ── Error parsing ─────────────────────────────────────────────────────────

  String _parseDioError(DioException e) {
    final data = e.response?.data;
    final statusCode = e.response?.statusCode;

    // Try to extract a server-provided message first.
    if (data is Map) {
      final serverMsg =
          data['message'] ?? data['error'] ?? data['msg'];
      if (serverMsg != null) return serverMsg.toString();
    }

    switch (statusCode) {
      case 400:
        return 'Invalid request. Check your input.';
      case 401:
        return 'Invalid credentials. Please try again.';
      case 403:
        return 'Account suspended. Contact support.';
      case 409:
        return 'An account with this email already exists.';
      case 429:
        return 'Too many attempts. Please wait and try again.';
      case 500:
        return 'Server error. Please try again later.';
    }

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Connection timed out. Check your internet connection.';
    }

    if (e.type == DioExceptionType.connectionError) {
      return 'Unable to reach the server. Check your connection.';
    }

    return 'Something went wrong. Please try again.';
  }
}
