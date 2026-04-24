import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile/core/constants/api_constants.dart';

/// Wraps an API call result into a discriminated union so callers never
/// need to catch exceptions themselves.
class AuthResult {
  final bool success;
  final String? token;
  final String? error;
  final double? weight;
  final String? email;

  const AuthResult._({
    required this.success,
    this.token,
    this.error,
    this.weight,
    this.email,
  });

  factory AuthResult.ok(String token, {double? weight, String? email}) =>
      AuthResult._(success: true, token: token, weight: weight, email: email);

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
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      // On some emulators, the shared prefs can be flaky; this ensures a clean retry.
      sharedPreferencesName: 'FitnessVault',
    ),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );
  static const _tokenKey = 'jwt_token';
  static const _weightKey = 'user_weight';
  static const _emailKey = 'user_email';

  // Helper for internal debugging
  Future<void> _log(String msg) async {
    if (kDebugMode) {
      print('🔐 [AuthService] $msg');
    }
  }

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
            await _log('Added Authorization header to request: ${options.uri}');
          } else {
            await _log('No token found for request: ${options.uri}');
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          // For now, don't delete token on 401, as it might be due to other issues
          // if (error.response?.statusCode == 401) {
          //   // Token was rejected by the server — wipe it locally.
          //   await deleteToken();
          // }
          return handler.next(error);
        },
      ),
    );
  }

  // ── Token helpers ─────────────────────────────────────────────────────────

  Future<void> saveToken(String token) async {
    await _log('Saving token...');
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<void> saveWeight(double weight) async {
    await _log('Saving weight: $weight');
    await _storage.write(key: _weightKey, value: weight.toString());
  }

  Future<void> saveEmail(String email) async {
    await _log('Saving email...');
    await _storage.write(key: _emailKey, value: email);
  }

  Future<String?> getToken() async {
    final token = await _storage.read(key: _tokenKey);
    if (token != null) {
      await _log('Token found in storage.');
    } else {
      await _log('No token found.');
    }
    return token;
  }

  Future<double?> getWeight() async {
    final weightStr = await _storage.read(key: _weightKey);
    if (weightStr != null) {
      return double.tryParse(weightStr);
    }
    return null;
  }

  Future<String?> getEmail() async {
    return await _storage.read(key: _emailKey);
  }

  Future<void> deleteToken() async {
    await _log('Deleting auth data.');
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _weightKey);
    await _storage.delete(key: _emailKey);
  }

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
    required double weight,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.signUp,
        data: {'email': email, 'password': password, 'weight': weight},
      );

      if (response.data['success'] == true) {
        final token = response.data['token'] as String;
        final resWeight = (response.data['user']?['weight'] as num?)?.toDouble();
        final resEmail = response.data['user']?['email'] as String?;

        await saveToken(token);
        if (resWeight != null) await saveWeight(resWeight);
        if (resEmail != null) await saveEmail(resEmail);

        return AuthResult.ok(token, weight: resWeight, email: resEmail);
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
        final resWeight = (response.data['user']?['weight'] as num?)?.toDouble();
        final resEmail = response.data['user']?['email'] as String?;

        await saveToken(token);
        if (resWeight != null) await saveWeight(resWeight);
        if (resEmail != null) await saveEmail(resEmail);

        return AuthResult.ok(token, weight: resWeight, email: resEmail);
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

  /// Updates only the user's weight.
  Future<AuthResult> updateWeight({
    required String email,
    required double weight,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.updateWeight,
        data: {'email': email, 'weight': weight},
      );

      if (response.data['success'] == true) {
        final resWeight = (response.data['user']?['weight'] as num?)?.toDouble();
        if (resWeight != null) {
          await saveWeight(resWeight);
        }
        return AuthResult.ok('', weight: resWeight);
      }

      return AuthResult.fail(
        response.data['message'] ?? 'Weight update failed.',
      );
    } on DioException catch (e) {
      return AuthResult.fail(_parseDioError(e));
    } catch (_) {
      return AuthResult.fail('An unexpected error occurred.');
    }
  }

  /// Inserts a new workout record.
  Future<AuthResult> insertWorkout({
    required String workoutObjective,
    required int duration,
    required int distance,
    required Map<String, dynamic> parcours,
    required Map<String, dynamic> reps,
    required int estimatedCalories,
  }) async {
    try {
      final token = await getToken();
      if (token == null) {
        return AuthResult.fail('No authentication token found.');
      }

      final requestData = {
        'workout_objective': workoutObjective,
        'duration': duration,
        'distance': distance,
        'parcours': parcours,
        'reps': reps,
        'estimated_calories': estimatedCalories,
      };

      await _log('Sending workout insert request with data: $requestData');

      final response = await _dio.post(
        ApiConstants.insertWorkout,
        data: requestData,
      );

      if (response.data['success'] == true) {
        return AuthResult.ok('');
      }

      return AuthResult.fail(
        response.data['message'] ?? 'Workout insertion failed.',
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
