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
import 'package:mobile/widgets/glass_card.dart';

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

    final greeting = _greeting();
    final emailName = (userProvider.email ?? 'Athlete').split('@').first;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: RefreshIndicator(
        onRefresh: () => workoutProvider.fetchWorkouts(),
        color: AppColors.secondary,
        backgroundColor: AppColors.darkSurface,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 96),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, greeting, emailName, workoutProvider),
              const SizedBox(height: 24),
              _buildDailySummary(context, workoutProvider, prefs),
              const SizedBox(height: 22),
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$greeting, $name', style: AppTextStyles.heading2),
              const SizedBox(height: 8),
              Text(
                workoutProvider.workoutsThisWeek > 0
                    ? '${workoutProvider.workoutsThisWeek} workout${workoutProvider.workoutsThisWeek == 1 ? '' : 's'} this week. Keep it up!'
                    : 'Start your first workout today.',
                style: AppTextStyles.body.copyWith(color: AppColors.white70),
              ),
            ],
          ),
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                ),
              ),
            ),
            const Icon(Icons.bar_chart_rounded, color: AppColors.white, size: 26),
          ],
        ).animate().scale(delay: 120.ms, duration: 750.ms),
      ],
    );
  }

  Widget _buildDailySummary(
    BuildContext context,
    WorkoutProvider workoutProvider,
    PreferencesProvider prefs,
  ) {
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

    return GlassCard(
      padding: const EdgeInsets.all(22),
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
                      style: AppTextStyles.label
                          ?.copyWith(color: AppColors.white54),
                    ),
                    const SizedBox(height: 8),
                    Text('Daily performance', style: AppTextStyles.heading3),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.white10,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.star_rounded,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: FitnessMetricTile(
                  label: 'Calories',
                  value: '$todayCalories kcal',
                  icon: Icons.local_fire_department_rounded,
                  accent: AppColors.secondary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: FitnessMetricTile(
                  label: 'Distance',
                  value: prefs.formatDistance(todayDistanceM),
                  icon: Icons.place_rounded,
                  accent: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: FitnessMetricTile(
                  label: 'Active',
                  value: '$todayActiveMin min',
                  icon: Icons.timer_rounded,
                  accent: AppColors.secondary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: FitnessMetricTile(
                  label: 'Sessions',
                  value: '${todayWorkouts.length}',
                  icon: Icons.directions_run_rounded,
                  accent: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Weekly goal',
                      style: AppTextStyles.label
                          ?.copyWith(color: AppColors.white54),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: weeklyProgress,
                      color: AppColors.secondary,
                      backgroundColor: AppColors.white12,
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
                    style: AppTextStyles.heading3,
                  ),
                  Text(
                    'of 30 ${prefs.distanceUnitLabel}',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.white54),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 700.ms);
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick actions', style: AppTextStyles.heading3),
        const SizedBox(height: 14),
        Row(
          children: [
            _actionTile(context, 'Run now', Icons.run_circle, AppColors.primary, '/plan'),
            const SizedBox(width: 14),
            _actionTile(context, 'Programs', Icons.auto_graph_rounded, AppColors.secondary, '/programs'),
            const SizedBox(width: 14),
            _actionTile(context, 'Analytics', Icons.show_chart_rounded, AppColors.white10, '/stats'),
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
    return Expanded(
      child: InkWell(
        onTap: () => context.go(route),
        borderRadius: BorderRadius.circular(22),
        child: GlassCard(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
          borderRadius: 22,
          child: Column(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(height: 16),
              Text(
                label,
                style: AppTextStyles.body
                    .copyWith(fontWeight: FontWeight.w700),
              ),
            ],
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
    final recent = workoutProvider.recentWorkouts.take(3).toList();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent workouts', style: AppTextStyles.heading3),
            GestureDetector(
              onTap: () => context.go('/stats'),
              child: Text(
                'See all',
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.secondary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (workoutProvider.isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(color: AppColors.secondary),
            ),
          )
        else if (recent.isEmpty)
          GlassCard(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Column(
                children: [
                  const Icon(
                    Icons.directions_run_rounded,
                    color: AppColors.white38,
                    size: 40,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No workouts yet.\nStart your first session!',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body
                        .copyWith(color: AppColors.white54),
                  ),
                ],
              ),
            ),
          )
        else
          Column(
            children: recent
                .map(
                  (w) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _activityRow(w, prefs),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }

  Widget _activityRow(WorkoutModel workout, PreferencesProvider prefs) {
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
      dateLabel =
          '${workout.createdAt.day}/${workout.createdAt.month}';
    }

    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.18),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.directions_run_rounded,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(workout.activityLabel, style: AppTextStyles.heading4),
                const SizedBox(height: 6),
                Text(
                  '${prefs.formatDistance(workout.distance)} • ${workout.formattedDuration}',
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.white54),
                ),
              ],
            ),
          ),
          Text(
            dateLabel,
            style: AppTextStyles.caption.copyWith(color: AppColors.white54),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCards(
    BuildContext context,
    WorkoutProvider workoutProvider,
    PreferencesProvider prefs,
  ) {
    final totalDistStr = prefs.formatDistance(workoutProvider.totalDistanceMeters);
    final totalCal = workoutProvider.totalCalories;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Progress summary', style: AppTextStyles.heading3),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _summaryCard(
                'Total distance',
                totalDistStr,
                '${workoutProvider.workouts.length} sessions',
                AppColors.primary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _summaryCard(
                'Calories burned',
                '$totalCal kcal',
                'All time',
                AppColors.secondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _summaryCard(
    String title,
    String value,
    String subtitle,
    Color accent,
  ) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.flash_on_rounded, color: accent),
          ),
          const SizedBox(height: 20),
          Text(value, style: AppTextStyles.heading3),
          const SizedBox(height: 10),
          Text(
            title,
            style: AppTextStyles.body.copyWith(color: AppColors.white70),
          ),
          const SizedBox(height: 14),
          Text(
            subtitle,
            style: AppTextStyles.caption.copyWith(color: AppColors.white54),
          ),
        ],
      ),
    );
  }
}
