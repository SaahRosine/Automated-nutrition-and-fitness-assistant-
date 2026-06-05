import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:mobile/providers/workout_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch workouts when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkoutProvider>().fetchWorkouts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final workoutProvider = context.watch<WorkoutProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sessions'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _MenuButton(
                  label: 'Start Session',
                  icon: Icons.play_arrow,
                  onTap: () => context.go('/plan'),
                ),
                const SizedBox(height: 12),
                _MenuButton(
                  label: 'Plan Session',
                  icon: Icons.edit_calendar,
                  onTap: () => context.go('/plan'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: workoutProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : workoutProvider.workouts.isEmpty
                    ? const Center(
                        child: Text(
                          'No sessions yet.\nStart your first session!',
                          textAlign: TextAlign.center,
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => workoutProvider.fetchWorkouts(),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: workoutProvider.recentWorkouts.length,
                          itemBuilder: (context, index) {
                            final workout = workoutProvider.recentWorkouts[index];
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
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _MenuButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 28),
        label: Text(label, style: const TextStyle(fontSize: 18)),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 20),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}