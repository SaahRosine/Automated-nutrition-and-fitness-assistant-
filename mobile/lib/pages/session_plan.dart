import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:mobile/providers/user_provider.dart';
import 'package:mobile/services/workout_service.dart';
import 'package:mobile/pages/session.dart';

class Exercise {
  final String name;
  final String emoji;
  final double calPerRep;
  int reps;

  Exercise({
    required this.name,
    required this.emoji,
    required this.calPerRep,
    this.reps = 10,
  });
}

// MET values for different activities and intensities
const Map<String, Map<String, double>> metValues = {
  'walking': {'low': 2.5, 'moderate': 3.5, 'high': 4.5},
  'running': {'low': 6.0, 'moderate': 8.0, 'high': 10.0},
  'cycling': {'low': 4.0, 'moderate': 6.0, 'high': 8.0},
  'bodyweight': {'low': 3.0, 'moderate': 5.0, 'high': 7.0},
};

// Calculate calories burned using MET formula
double calculateCalories({
  required String workoutType,
  required String intensity,
  required double weightKg,
  required int durationMinutes,
}) {
  final met = metValues[workoutType]?[intensity];
  if (met == null || weightKg <= 0 || durationMinutes <= 0) {
    return 0;
  }
  final durationHours = durationMinutes / 60.0;
  return met * weightKg * durationHours;
}

class SessionPlan extends StatefulWidget {
  const SessionPlan({super.key});

  @override
  State<SessionPlan> createState() => _SessionPlanState();
}

class _SessionPlanState extends State<SessionPlan> {
  int _durationMinutes = 30;
  String _workoutType = 'running';
  String _intensity = 'moderate';

  final List<Exercise> _exercises = [
    Exercise(name: 'Push-ups', emoji: '💪', calPerRep: 0.5),
    Exercise(name: 'Squats', emoji: '🦵', calPerRep: 0.4),
    Exercise(name: 'Sit-ups', emoji: '🏋️', calPerRep: 0.3),
  ];

  int _calculateWorkoutCalories(double? weight) {
    if (weight == null || weight <= 0) return 0;
    return calculateCalories(
      workoutType: _workoutType,
      intensity: _intensity,
      weightKg: weight,
      durationMinutes: _durationMinutes,
    ).round();
  }

  int get _exerciseCal =>
      _exercises.fold(0, (sum, e) => sum + (e.reps * e.calPerRep).round());

  int _calculateTotalCalories(double? weight) =>
      _calculateWorkoutCalories(weight) + _exerciseCal;

  void _showAddExerciseSheet() {
    final nameController = TextEditingController();
    double calPerRep = 0.4;

    final presets = [
      Exercise(name: 'Lunges', emoji: '🚶', calPerRep: 0.4),
      Exercise(name: 'Burpees', emoji: '🔥', calPerRep: 1.0),
      Exercise(name: 'Jumping Jacks', emoji: '⚡', calPerRep: 0.2),
      Exercise(name: 'Pull-ups', emoji: '🏅', calPerRep: 0.8),
      Exercise(name: 'Plank (sec)', emoji: '🧱', calPerRep: 0.1),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add Exercise',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('Quick add', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: presets.map((ex) {
                return ActionChip(
                  avatar: Text(ex.emoji),
                  label: Text(ex.name),
                  onPressed: () {
                    setState(() => _exercises.add(ex));
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 8),
            const Text('Custom', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Exercise name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            StatefulBuilder(
              builder: (context, setLocal) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Estimated ${calPerRep.toStringAsFixed(1)} kcal / rep',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  Slider(
                    value: calPerRep,
                    min: 0.1,
                    max: 2.0,
                    divisions: 19,
                    label: calPerRep.toStringAsFixed(1),
                    onChanged: (v) => setLocal(() => calPerRep = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  if (nameController.text.trim().isEmpty) return;
                  setState(() {
                    _exercises.add(
                      Exercise(
                        name: nameController.text.trim(),
                        emoji: '🏃',
                        calPerRep: calPerRep,
                      ),
                    );
                  });
                  Navigator.pop(context);
                },
                child: const Text('Add'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userProvider = context.watch<UserProvider>();
    final weight = userProvider.weight;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Plan session',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Workout ──────────────────────────────────
          _SectionLabel('Workout'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _CircleIconButton(
                        icon: Icons.remove,
                        onTap: () => setState(() {
                          if (_durationMinutes > 5) _durationMinutes -= 5;
                        }),
                      ),
                      const SizedBox(width: 24),
                      Column(
                        children: [
                          Text(
                            '$_durationMinutes',
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'minutes',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(width: 24),
                      _CircleIconButton(
                        icon: Icons.add,
                        onTap: () => setState(() {
                          if (_durationMinutes < 120) _durationMinutes += 5;
                        }),
                      ),
                    ],
                  ),
                   Slider(
                     value: _durationMinutes.toDouble(),
                     min: 5,
                     max: 120,
                     divisions: 23,
                     label: '$_durationMinutes min',
                     onChanged: (v) =>
                         setState(() => _durationMinutes = v.round()),
                   ),
                   const SizedBox(height: 16),
                   // Workout type selection
                   const Text('Workout Type', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                   const SizedBox(height: 8),
                   Wrap(
                     spacing: 8,
                     children: metValues.keys.map((type) {
                       final isSelected = _workoutType == type;
                       return FilterChip(
                         label: Text(type[0].toUpperCase() + type.substring(1)),
                         selected: isSelected,
                         onSelected: (selected) {
                           if (selected) setState(() => _workoutType = type);
                         },
                       );
                     }).toList(),
                   ),
                   const SizedBox(height: 16),
                   // Intensity selection
                   const Text('Intensity', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                   const SizedBox(height: 8),
                   Wrap(
                     spacing: 8,
                     children: ['low', 'moderate', 'high'].map((intensity) {
                       final isSelected = _intensity == intensity;
                       return FilterChip(
                         label: Text(intensity[0].toUpperCase() + intensity.substring(1)),
                         selected: isSelected,
                         onSelected: (selected) {
                           if (selected) setState(() => _intensity = intensity);
                         },
                       );
                     }).toList(),
                   ),
                   const SizedBox(height: 16),
                    _CalChip(
                      value: _calculateWorkoutCalories(weight),
                      label: 'kcal estimated',
                      color: weight != null ? Colors.blue.shade50 : Colors.grey.shade50,
                      textColor: weight != null ? Colors.blue.shade800 : Colors.grey.shade600,
                    ),
                  ],
                ),
              ),
            ),

          // Add exercise button
          OutlinedButton.icon(
            onPressed: _showAddExerciseSheet,
            icon: const Icon(Icons.add),
            label: const Text('Add exercise'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(44),
              side: const BorderSide(style: BorderStyle.solid),
            ),
          ),

          const SizedBox(height: 20),

          // ── Total calories ────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total estimated',
                      style: TextStyle(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'running + exercises',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onPrimaryContainer.withOpacity(
                          0.7,
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                     Text(
                       '${_calculateTotalCalories(weight)}',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    Text(
                      'kcal',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onPrimaryContainer.withOpacity(
                          0.7,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          FilledButton(
            onPressed: () async {
              final weight = userProvider.weight;
              if (weight == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please set your weight in settings first')),
                );
                return;
              }

              final workoutService = WorkoutService();
              final workoutObjective = '${_workoutType}_${_intensity}';
              final duration = _durationMinutes;
              final distance = 1; // Placeholder — real distance tracked during session
              final parcours = {
                'exercises': _exercises.map((e) => {
                  'name': e.name,
                  'emoji': e.emoji,
                  'reps': e.reps,
                  'calPerRep': e.calPerRep,
                }).toList(),
              };
              final reps = Map<String, dynamic>.fromEntries(
                _exercises.map((e) => MapEntry(
                  e.name.toLowerCase().replaceAll(' ', ''),
                  e.reps,
                )),
              );
              final estimatedCalories = _calculateTotalCalories(weight).round();

              final result = await workoutService.submitWorkout(
                workoutObjective: workoutObjective,
                duration: duration,
                distance: distance,
                parcours: parcours,
                reps: reps,
                calories: estimatedCalories,
              );

              if (result.success) {
                if (mounted) {
                  context.push('/session/active', extra: {
                    'exercises': _exercises,
                    'workoutType': _workoutType,
                    'intensity': _intensity,
                    'duration': _durationMinutes,
                    'estimatedCalories': estimatedCalories,
                  });
                }
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(result.error ?? 'Failed to start session')),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              backgroundColor: Colors.green.shade700,
            ),
            child: const Text('Start session', style: TextStyle(fontSize: 16)),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
        color: Colors.grey,
      ),
    ),
  );
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(24),
    child: Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Icon(icon),
    ),
  );
}

class _CalChip extends StatelessWidget {
  const _CalChip({
    required this.value,
    required this.label,
    required this.color,
    required this.textColor,
  });
  final int value;
  final String label;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(10),
    ),
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
    child: Column(
      children: [
        Text(
          '$value',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: textColor),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}
