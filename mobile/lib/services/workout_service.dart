import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/models/workout_model.dart';
import 'package:mobile/services/auth_service.dart';

/// Result wrapper for workout API calls.
class WorkoutResult {
  final bool success;
  final String? error;
  final List<WorkoutModel> workouts;

  const WorkoutResult._({
    required this.success,
    this.error,
    this.workouts = const [],
  });

  factory WorkoutResult.ok(List<WorkoutModel> workouts) =>
      WorkoutResult._(success: true, workouts: workouts);

  factory WorkoutResult.fail(String message) =>
      WorkoutResult._(success: false, error: message);
}

/// Handles all workout-related HTTP calls.
///
/// Shares the same Dio instance pattern as [AuthService] — the auth
/// interceptor automatically attaches the Bearer token.
class WorkoutService {
  late final Dio _dio;
  final AuthService _authService;

  WorkoutService({AuthService? authService})
      : _authService = authService ?? AuthService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _authService.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }

  /// Fetches all workouts for the authenticated user.
  Future<WorkoutResult> getWorkouts() async {
    try {
      final response = await _dio.get(ApiConstants.getWorkouts);

      if (response.data['success'] == true) {
        final rawList = response.data['data'] as List<dynamic>? ?? [];
        final workouts = rawList
            .map((e) => WorkoutModel.fromJson(e as Map<String, dynamic>))
            .toList();
        return WorkoutResult.ok(workouts);
      }

      return WorkoutResult.fail(
        response.data['message'] ?? 'Failed to fetch workouts.',
      );
    } on DioException catch (e) {
      return WorkoutResult.fail(_parseDioError(e));
    } catch (_) {
      return WorkoutResult.fail('An unexpected error occurred.');
    }
  }

  /// Submits a completed workout session to the backend.
  ///
  /// Uses [ApiConstants.insertWorkout] (`POST /workout/insert`).
  Future<WorkoutResult> submitWorkout({
    required String workoutObjective,
    required int duration,
    required int distance,
    required Map<String, dynamic> parcours,
    required Map<String, dynamic> reps,
    required int calories,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.insertWorkout,
        data: {
          'workout_objective': workoutObjective,
          'duration': duration,
          'distance': distance,
          'parcours': parcours,
          'reps': reps,
          'estimated_calories': calories,
        },
      );

      if (response.data['success'] == true) {
        return WorkoutResult.ok([]);
      }

      return WorkoutResult.fail(
        response.data['message'] ?? 'Failed to submit workout.',
      );
    } on DioException catch (e) {
      if (kDebugMode) print('WorkoutService.submitWorkout error: $e');
      return WorkoutResult.fail(_parseDioError(e));
    } catch (_) {
      return WorkoutResult.fail('An unexpected error occurred.');
    }
  }

  String _parseDioError(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      final msg = data['message'] ?? data['error'];
      if (msg != null) return msg.toString();
    }
    switch (e.response?.statusCode) {
      case 400: return 'Invalid request.';
      case 401: return 'Session expired. Please log in again.';
      case 403: return 'Access denied.';
      case 500: return 'Server error. Please try again later.';
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Connection timed out.';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'Unable to reach the server.';
    }
    return 'Something went wrong.';
  }
}
