import 'package:flutter/foundation.dart';
import 'package:mobile/models/workout_model.dart';
import 'package:mobile/services/workout_service.dart';

/// Holds the user's workout history and exposes derived stats.
///
/// Call [fetchWorkouts] once after login (or on pull-to-refresh).
class WorkoutProvider extends ChangeNotifier {
  final WorkoutService _workoutService;

  WorkoutProvider({WorkoutService? workoutService})
      : _workoutService = workoutService ?? WorkoutService();

  // ── State ──────────────────────────────────────────────────────────────────
  bool _isLoading = false;
  List<WorkoutModel> _workouts = [];
  String? _errorMessage;

  // ── Getters ────────────────────────────────────────────────────────────────
  bool get isLoading => _isLoading;
  List<WorkoutModel> get workouts => List.unmodifiable(_workouts);
  String? get errorMessage => _errorMessage;

  /// Most recent workouts first.
  List<WorkoutModel> get recentWorkouts {
    final sorted = [..._workouts]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted;
  }

  // ── Derived stats ──────────────────────────────────────────────────────────

  /// Total distance across all workouts, in metres.
  int get totalDistanceMeters =>
      _workouts.fold(0, (sum, w) => sum + w.distance);

  /// Total calories burned across all workouts.
  int get totalCalories =>
      _workouts.fold(0, (sum, w) => sum + w.calories);

  /// Total active time across all workouts, in seconds.
  int get totalDurationSeconds =>
      _workouts.fold(0, (sum, w) => sum + w.duration);

  /// Number of workouts completed this week (Mon–Sun).
  int get workoutsThisWeek {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final start = DateTime(weekStart.year, weekStart.month, weekStart.day);
    return _workouts.where((w) => w.createdAt.isAfter(start)).length;
  }

  /// Total distance this week, in metres.
  int get distanceThisWeekMeters {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final start = DateTime(weekStart.year, weekStart.month, weekStart.day);
    return _workouts
        .where((w) => w.createdAt.isAfter(start))
        .fold(0, (sum, w) => sum + w.distance);
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  Future<void> fetchWorkouts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _workoutService.getWorkouts();

    if (result.success) {
      _workouts = result.workouts;
    } else {
      _errorMessage = result.error;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Optimistically prepend a newly submitted workout so the UI updates
  /// immediately without waiting for a re-fetch.
  void addWorkout(WorkoutModel workout) {
    _workouts = [workout, ..._workouts];
    notifyListeners();
  }

  void clear() {
    _workouts = [];
    _errorMessage = null;
    notifyListeners();
  }
}
