import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:mobile/core/constants/app_styles.dart';
import 'package:mobile/models/workout_model.dart';
import 'package:mobile/providers/preferences_provider.dart';
import 'package:mobile/providers/user_provider.dart';
import 'package:mobile/providers/workout_provider.dart';
import 'package:mobile/widgets/fitness_metric_tile.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh workout data whenever the dashboard is shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkoutProvider>().fetchWorkouts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final workoutProvider = context.watch<WorkoutProvider>();
    final prefs = context.watch<PreferencesProvider>();
    final theme = Theme.of(context);

    final greeting = _greeting();
    final emailName = (userProvider.email ?? 'Athlete').split('@').first;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: RefreshIndicator(
        onRefresh: () => workoutProvider.fetchWorkouts(),
        color: theme.colorScheme.secondary,
        backgroundColor: theme.colorScheme.surface,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 96),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, greeting, emailName, workoutProvider),
              const SizedBox(height: 24),
              _buildDailySummary(context, workoutProvider, prefs),
              const SizedBox(height: 24),
              _buildQuickActions(context),
              const SizedBox(height: 24),
              _buildRecentWorkouts(context, workoutProvider, prefs),
              const SizedBox(height: 24),
              _buildProgressCards(context, workoutProvider, prefs),
            ],
          ),
        ),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Widget _buildHeader(
    BuildContext context,
    String greeting,
    String name,
    WorkoutProvider workoutProvider,
  ) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$greeting, $name', style: AppTextStyles.heading2(context)),
              const SizedBox(height: 8),
              Text(
                workoutProvider.workoutsThisWeek > 0
                    ? '${workoutProvider.workoutsThisWeek} workout${workoutProvider.workoutsThisWeek == 1 ? '' : 's'} this week. Keep it up!'
                    : 'Start your first workout today.',
                style: AppTextStyles.body(context).copyWith(
                  color: theme.colorScheme.onBackground.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
            ),
          ),
          child: const Icon(Icons.bar_chart_rounded, color: Colors.white, size: 28),
        ).animate().scale(delay: 120.ms, duration: 750.ms),
      ],
    );
  }

  Widget _buildDailySummary(
    BuildContext context,
    WorkoutProvider workoutProvider,
    PreferencesProvider prefs,
  ) {
    final theme = Theme.of(context);
    // Today's aggregated stats
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayWorkouts = workoutProvider.workouts
        .where((w) => w.createdAt.isAfter(todayStart))
        .toList();

    final todaySteps = 0; // Steps not stored in backend yet
    final todayCalories = todayWorkouts.fold(0, (s, w) => s + w.calories);
    final todayDistanceM = todayWorkouts.fold(0, (s, w) => s + w.distance);
    final todayActiveMin =
        todayWorkouts.fold(0, (s, w) => s + w.duration) ~/ 60;

    // Weekly goal progress (target: 30km/week)
    final weeklyTargetM = 30000;
    final weeklyDistM = workoutProvider.distanceThisWeekMeters;
    final weeklyProgress = (weeklyDistM / weeklyTargetM).clamp(0.0, 1.0);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Today',
                        style: AppTextStyles.label(context),
                      ),
                      const SizedBox(height: 8),
                      Text('Daily performance', style: AppTextStyles.heading3(context)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.star_rounded,
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FitnessMetricTile(
                    label: 'Calories',
                    value: '$todayCalories kcal',
                    icon: Icons.local_fire_department_rounded,
                    accent: theme.colorScheme.secondary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FitnessMetricTile(
                    label: 'Distance',
                    value: prefs.formatDistance(todayDistanceM),
                    icon: Icons.place_rounded,
                    accent: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FitnessMetricTile(
                    label: 'Active',
                    value: '$todayActiveMin min',
                    icon: Icons.timer_rounded,
                    accent: theme.colorScheme.secondary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FitnessMetricTile(
                    label: 'Sessions',
                    value: '${todayWorkouts.length}',
                    icon: Icons.directions_run_rounded,
                    accent: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Weekly goal',
                        style: AppTextStyles.label(context),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: weeklyProgress,
                        color: theme.colorScheme.secondary,
                        backgroundColor: theme.colorScheme.surfaceVariant,
                        minHeight: 8,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${(weeklyProgress * 100).round()}%',
                      style: AppTextStyles.heading3(context),
                    ),
                    Text(
                      'of 30 ${prefs.distanceUnitLabel}',
                      style: AppTextStyles.caption(context),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 700.ms);
  }

  Widget _buildQuickActions(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick actions', style: AppTextStyles.heading3(context)),
        const SizedBox(height: 16),
        Row(
          children: [
            _actionTile(context, 'Run now', Icons.run_circle, theme.colorScheme.primary, '/plan'),
            const SizedBox(width: 16),
            _actionTile(context, 'Programs', Icons.auto_graph_rounded, theme.colorScheme.secondary, '/programs'),
            const SizedBox(width: 16),
            _actionTile(context, 'Analytics', Icons.show_chart_rounded, theme.colorScheme.surfaceVariant, '/stats'),
          ],
        ),
      ],
    );
  }

  Widget _actionTile(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    String route,
  ) {
    final theme = Theme.of(context);
    return Expanded(
      child: InkWell(
        onTap: () => context.go(route),
        borderRadius: BorderRadius.circular(16),
        child: Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Column(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.18),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(height: 16),
                Text(
                  label,
                  style: AppTextStyles.body(context).copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentWorkouts(
    BuildContext context,
    WorkoutProvider workoutProvider,
    PreferencesProvider prefs,
  ) {
    final theme = Theme.of(context);
    final recent = workoutProvider.recentWorkouts.take(3).toList();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent workouts', style: AppTextStyles.heading3(context)),
            GestureDetector(
              onTap: () => context.go('/stats'),
              child: Text(
                'See all',
                style: AppTextStyles.caption(context).copyWith(
                  color: theme.colorScheme.secondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (workoutProvider.isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          )
        else if (recent.isEmpty)
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.directions_run_rounded,
                      color: theme.colorScheme.onBackground.withOpacity(0.4),
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No workouts yet.\nStart your first session!',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body(context).copyWith(
                        color: theme.colorScheme.onBackground.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          Column(
            children: recent
                .map(
                  (w) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _activityRow(w, prefs),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }

  Widget _activityRow(WorkoutModel workout, PreferencesProvider prefs) {
    final theme = Theme.of(context);
    final isToday = workout.createdAt.day == DateTime.now().day &&
        workout.createdAt.month == DateTime.now().month;
    final isYesterday = workout.createdAt.day == DateTime.now().day - 1 &&
        workout.createdAt.month == DateTime.now().month;

    String dateLabel;
    if (isToday) {
      dateLabel = 'Today';
    } else if (isYesterday) {
      dateLabel = 'Yesterday';
    } else {
      dateLabel = '${workout.createdAt.day}/${workout.createdAt.month}';
    }

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.18),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.directions_run_rounded,
                color: theme.colorScheme.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(workout.activityLabel, style: AppTextStyles.heading4(context)),
                  const SizedBox(height: 4),
                  Text(
                    '${prefs.formatDistance(workout.distance)} • ${workout.formattedDuration}',
                    style: AppTextStyles.caption(context),
                  ),
                ],
              ),
            ),
            Text(
              dateLabel,
              style: AppTextStyles.caption(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCards(
    BuildContext context,
    WorkoutProvider workoutProvider,
    PreferencesProvider prefs,
  ) {
    final theme = Theme.of(context);
    final totalDistStr = prefs.formatDistance(workoutProvider.totalDistanceMeters);
    final totalCal = workoutProvider.totalCalories;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Progress summary', style: AppTextStyles.heading3(context)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _summaryCard(
                context,
                'Total distance',
                totalDistStr,
                '${workoutProvider.workouts.length} sessions',
                theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _summaryCard(
                context,
                'Calories burned',
                '$totalCal kcal',
                'All time',
                theme.colorScheme.secondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _summaryCard(
    BuildContext context,
    String title,
    String value,
    String subtitle,
    Color accent,
  ) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.flash_on_rounded, color: accent),
            ),
            const SizedBox(height: 16),
            Text(value, style: AppTextStyles.heading3(context)),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppTextStyles.body(context).copyWith(
                color: theme.colorScheme.onBackground.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: AppTextStyles.caption(context),
            ),
          ],
        ),
      ),
    );
  }
}
