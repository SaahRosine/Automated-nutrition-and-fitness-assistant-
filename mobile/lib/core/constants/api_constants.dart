import 'dart:io' show Platform;

/// Central API configuration.
/// Android emulators reach the host machine via 10.0.2.2.
/// iOS simulators use localhost directly.
class ApiConstants {
  ApiConstants._(); // prevent instantiation

  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://192.168.1.152:4000/api';
    }
    return 'http://localhost:4000/api';
  }

  // ── Auth endpoints ────────────────────────────────────────────────────────
  static const String signUp = '/sign-up';
  static const String login = '/login';
  static const String rotateToken = '/rotate-token';
  static const String updateProfile = '/update';
  static const String deleteAccount = '/delete';
  static const String updateWeight = '/update-weight';

  // ── Workout endpoints ──────────────────────────────────────────────────────
  static const String insertWorkout = '/workout/insert';
}
