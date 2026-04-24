import 'package:flutter/material.dart';
import 'package:mobile/pages/session_plan.dart';

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
                    '${widget.workoutType[0].toUpperCase() + widget.workoutType.substring(1)} (${widget.intensity})',
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
                    color: theme.colorScheme.surfaceVariant,
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

          // Finish button (placeholder)
          FilledButton(
            onPressed: () {
              // TODO: finish session and save completion
              Navigator.pop(context);
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
