import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/core/constants/app_styles.dart';
import 'package:mobile/pages/session_plan.dart';
import 'package:mobile/providers/user_provider.dart';
import 'package:mobile/providers/workout_provider.dart';
import 'package:mobile/services/session_controller.dart';
import 'package:mobile/services/workout_service.dart';

class Session extends StatefulWidget {
  const Session({
    super.key,
    required this.exercises,
    required this.workoutType,
    required this.intensity,
    required this.duration,
    required this.estimatedCalories,
  });

  final List<Exercise> exercises;
  final String workoutType;
  final String intensity;
  final int duration;
  final int estimatedCalories;

  @override
  State<Session> createState() => _SessionState();
}

class _SessionState extends State<Session> {
  final SessionController _sessionController = SessionController();

  // Live data
  int _steps = 0;
  double _distance = 0.0;
  int _elapsedSeconds = 0;
  int _calories = 0;

  @override
  void initState() {
    super.initState();
    _startSession();
  }

  Future<void> _startSession() async {
    final hasPermissions = await _sessionController.requestPermissions();
    if (!hasPermissions) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permissions required for tracking. Please grant location and activity permissions.'),
          ),
        );
      }
      return;
    }

    _sessionController.startSession();

    // Listen to streams
    _sessionController.stepStream.listen((steps) {
      if (mounted) setState(() => _steps = steps);
    });

    _sessionController.distanceStream.listen((distance) {
      if (mounted) setState(() => _distance = distance);
    });

    _sessionController.elapsedTimeStream.listen((seconds) {
      if (mounted) {
        setState(() => _elapsedSeconds = seconds);
        _updateCalories();
      }
    });
  }

  void _updateCalories() {
    final userProvider = context.read<UserProvider>();
    final weight = userProvider.weight;
    if (weight != null) {
      _calories = _sessionController.calculateCalories(
        weightKg: weight,
        workoutType: widget.workoutType,
        intensity: widget.intensity,
      );
      setState(() {});
    }
  }

  @override
  void dispose() {
    _sessionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Active Session',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.workoutType[0].toUpperCase()}${widget.workoutType.substring(1)} (${widget.intensity})',
                    style: AppTextStyles.heading3(context),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Duration: ${widget.duration} minutes',
                    style: AppTextStyles.body(context).copyWith(
                      color: theme.colorScheme.onBackground.withOpacity(0.6),
                    ),
                  ),
                  Text(
                    'Estimated calories: ${widget.estimatedCalories}',
                    style: AppTextStyles.body(context).copyWith(
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Live Stats',
                    style: AppTextStyles.heading3(context),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _StatItem(
                        icon: Icons.directions_run,
                        value: '$_steps',
                        label: 'Steps',
                        color: theme.colorScheme.primary,
                      ),
                      _StatItem(
                        icon: Icons.straighten,
                        value: (_distance / 1000).toStringAsFixed(2),
                        label: 'km',
                        color: theme.colorScheme.secondary,
                      ),
                      _StatItem(
                        icon: Icons.timer,
                        value: _formatTime(_elapsedSeconds),
                        label: 'Time',
                        color: AppColors.warning,
                      ),
                      _StatItem(
                        icon: Icons.local_fire_department,
                        value: '$_calories',
                        label: 'kcal',
                        color: AppColors.error,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'Exercises',
            style: AppTextStyles.heading3(context),
          ),
          const SizedBox(height: 16),
          ...widget.exercises.map((exercise) {
            final cal = (exercise.reps * exercise.calPerRep).round();
            return Card(
              child: ListTile(
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      exercise.emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                title: Text(exercise.name, style: AppTextStyles.body(context)),
                subtitle: Text(
                  '${exercise.reps} reps • ${cal} kcal',
                  style: AppTextStyles.caption(context),
                ),
                trailing: Icon(
                  Icons.check_circle_outline,
                  color: theme.colorScheme.primary,
                ),
              ),
            );
          }),

          const SizedBox(height: 24),

          FilledButton(
            onPressed: () async {
              _sessionController.stopSession();

              final userProvider = context.read<UserProvider>();
              final weight = userProvider.weight;

              if (weight == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Weight not available')),
                );
                return;
              }

              final sessionData = _sessionController.getSessionData(
                weightKg: weight,
                workoutType: widget.workoutType,
                intensity: widget.intensity,
              );

              final parcours = <String, dynamic>{
                'path': _sessionController.locationService.positions
                    .map((p) => {'lat': p.latitude, 'lng': p.longitude})
                    .toList(),
              };

              final reps = Map<String, dynamic>.fromEntries(
                widget.exercises.map((e) => MapEntry(
                  e.name.toLowerCase().replaceAll(' ', ''),
                  e.reps,
                )),
              );

              final workoutService = WorkoutService();
              final result = await workoutService.submitWorkout(
                workoutObjective: '${widget.workoutType}_${widget.intensity}',
                duration: sessionData.duration,
                distance: sessionData.distance.round(),
                parcours: parcours,
                reps: reps,
                calories: sessionData.calories,
              );

              if (result.success) {
                if (mounted) {
                  context.read<WorkoutProvider>().fetchWorkouts();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Session completed successfully!')),
                  );
                  Navigator.pop(context);
                }
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(result.error ?? 'Failed to save session')),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
              backgroundColor: AppColors.error,
            ),
            child: const Text('Finish Session', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onBackground,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.onBackground.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}

String _formatTime(int seconds) {
  final hours = seconds ~/ 3600;
  final minutes = (seconds % 3600) ~/ 60;
  final secs = seconds % 60;

  if (hours > 0) {
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  } else {
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}
