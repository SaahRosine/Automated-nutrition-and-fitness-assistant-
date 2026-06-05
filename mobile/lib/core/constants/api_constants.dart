import 'dart:io' show Platform;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Central API configuration.
/// Android emulators reach the host machine via 10.0.2.2.
/// iOS simulators use localhost directly.
class ApiConstants {
  ApiConstants._(); // prevent instantiation

  static String get baseUrl {
    final env = dotenv.env['BASE_URL_ANDROID'] ?? 'http://10.0.2.2:4000';
    // Ensure /api is appended if not already present
    return env.endsWith('/api') ? env : '$env/api';
  }

  static String get nutritionUrl {
    // For Android emulator, use 10.0.2.2. For physical device, use machine IP.
    return dotenv.env['NUTRITION_URL'] ?? 'http://10.0.2.2:8000';
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
  static const String getWorkouts = '/workout/output';
}
