import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/pages/session_plan.dart';
import 'package:mobile/providers/user_provider.dart';
import 'package:mobile/services/session_controller.dart';
import 'package:mobile/services/auth_service.dart';

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
          // Session info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.workoutType[0].toUpperCase()}${widget.workoutType.substring(1)} (${widget.intensity})',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Duration: ${widget.duration} minutes',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  Text(
                    'Estimated calories: ${widget.estimatedCalories}',
                    style: TextStyle(color: Colors.green[700]),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Live stats
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Live Stats',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _StatItem(
                        icon: Icons.directions_run,
                        value: '$_steps',
                        label: 'Steps',
                        color: Colors.blue,
                      ),
                      _StatItem(
                        icon: Icons.straighten,
                        value: (_distance / 1000).toStringAsFixed(2),
                        label: 'km',
                        color: Colors.green,
                      ),
                      _StatItem(
                        icon: Icons.timer,
                        value: _formatTime(_elapsedSeconds),
                        label: 'Time',
                        color: Colors.orange,
                      ),
                      _StatItem(
                        icon: Icons.local_fire_department,
                        value: '$_calories',
                        label: 'kcal',
                        color: Colors.red,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Exercises
          const Text(
            'Exercises',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...widget.exercises.map((exercise) {
            final cal = (exercise.reps * exercise.calPerRep).round();
            return Card(
              child: ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      exercise.emoji,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                title: Text(exercise.name),
                subtitle: Text('${exercise.reps} reps • ${cal} kcal'),
                trailing: const Icon(Icons.check_circle_outline),
              ),
            );
          }),

          const SizedBox(height: 20),

          // Finish button
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

              // Save to backend
              final authService = AuthService();
              final result = await authService.updateWorkout(
                workoutObjective: '${widget.workoutType}_${widget.intensity}',
                duration: sessionData.duration,
                distance: sessionData.distance.round(),
                reps: {}, // Could be updated if exercises are completed
                actualCalories: sessionData.calories,
                steps: sessionData.steps,
              );

              if (result.success) {
                if (mounted) {
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
              minimumSize: const Size.fromHeight(52),
              backgroundColor: Colors.red.shade700,
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
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
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
