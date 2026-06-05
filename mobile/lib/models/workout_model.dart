/// Represents a single completed workout record from the backend.
class WorkoutModel {
  final String id;
  final String userId;
  final String? workoutObjectiveId;
  final DateTime createdAt;
  final int duration; // seconds
  final int distance; // meters
  final int calories;
  final Map<String, dynamic> parcours;
  final Map<String, dynamic> reps;

  const WorkoutModel({
    required this.id,
    required this.userId,
    this.workoutObjectiveId,
    required this.createdAt,
    required this.duration,
    required this.distance,
    required this.calories,
    required this.parcours,
    required this.reps,
  });

  factory WorkoutModel.fromJson(Map<String, dynamic> json) {
    return WorkoutModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      workoutObjectiveId: json['workout_objective_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      duration: (json['duration'] as num).toInt(),
      distance: (json['distance'] as num).toInt(),
      calories: (json['calories'] as num).toInt(),
      parcours: (json['parcours'] as Map<String, dynamic>?) ?? {},
      reps: (json['reps'] as Map<String, dynamic>?) ?? {},
    );
  }

  /// Distance in kilometres, rounded to 2 decimal places.
  double get distanceKm => distance / 1000.0;

  /// Duration formatted as MM:SS or HH:MM:SS.
  String get formattedDuration {
    final h = duration ~/ 3600;
    final m = (duration % 3600) ~/ 60;
    final s = duration % 60;
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  /// Human-readable label derived from the workout_objective_id (e.g. "running_moderate").
  String get activityLabel {
    if (workoutObjectiveId == null) return 'Workout';
    final parts = workoutObjectiveId!.split('_');
    if (parts.isEmpty) return 'Workout';
    return parts.map((p) => p[0].toUpperCase() + p.substring(1)).join(' ');
  }
}
