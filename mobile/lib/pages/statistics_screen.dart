import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/providers/workout_provider.dart';
import 'package:mobile/models/workout_model.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final workoutProvider = context.watch<WorkoutProvider>();
    final workouts = workoutProvider.workouts;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () => workoutProvider.fetchWorkouts(),
        child: workouts.isEmpty
            ? const Center(
                child: Text('No sessions yet.\nStart your first session!'),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: workouts.length,
                itemBuilder: (context, index) {
                  final workout = workouts[index];
                  return _SessionCard(workout: workout);
                },
              ),
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final WorkoutModel workout;

  const _SessionCard({required this.workout});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(workout.activityLabel),
        subtitle: Text(
          '${workout.formattedDuration} • ${workout.distance ~/ 1000}km • ${workout.calories} kcal',
        ),
        trailing: Text(
          '${workout.createdAt.day}/${workout.createdAt.month}',
          style: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}