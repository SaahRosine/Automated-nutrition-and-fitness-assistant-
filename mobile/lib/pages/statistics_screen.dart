import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:mobile/core/constants/app_styles.dart';
import 'package:mobile/models/workout_model.dart';
import 'package:mobile/providers/preferences_provider.dart';
import 'package:mobile/providers/workout_provider.dart';
import 'package:mobile/widgets/glass_card.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkoutProvider>().fetchWorkouts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final workoutProvider = context.watch<WorkoutProvider>();
    final prefs = context.watch<PreferencesProvider>();
    final workouts = workoutProvider.recentWorkouts;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: RefreshIndicator(
        onRefresh: () => workoutProvider.fetchWorkouts(),
        color: AppColors.secondary,
        backgroundColor: AppColors.darkSurface,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Statistics', style: AppTextStyles.heading2),
                const SizedBox(height: 8),
                Text(
                  'Track your improvement with clear analytics.',
                  style: AppTextStyles.body.copyWith(color: AppColors.white70),
                ),
                const SizedBox(height: 24),

                // ── Weekly distance chart ─────────────────────────────────
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Weekly distance (${prefs.distanceUnitLabel})',
                          style: AppTextStyles.heading4),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 210,
                        child: _WeeklyDistanceChart(
                          workouts: workouts,
                          prefs: prefs,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 700.ms),

                const SizedBox(height: 20),

                // ── Best stats row ────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: _statTile(
                        'Longest run',
                        workouts.isEmpty
                            ? '--'
                            : prefs.formatDistance(
                                workouts
                                    .map((w) => w.distance)
                                    .reduce((a, b) => a > b ? a : b),
                              ),
                        AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _statTile(
                        'Best session',
                        workouts.isEmpty
                            ? '--'
                            : workouts
                                .reduce((a, b) =>
                                    a.calories > b.calories ? a : b)
                                .formattedDuration,
                        AppColors.secondary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ── Calories chart ────────────────────────────────────────
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Calories trend', style: AppTextStyles.heading4),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 210,
                        child: _WeeklyCaloriesChart(workouts: workouts),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // ── Personal records ──────────────────────────────────────
                Text('Personal records', style: AppTextStyles.heading3),
                const SizedBox(height: 14),
                _recordTile(
                  'Longest distance',
                  workouts.isEmpty
                      ? '--'
                      : prefs.formatDistance(
                          workouts
                              .map((w) => w.distance)
                              .reduce((a, b) => a > b ? a : b),
                        ),
                  AppColors.primary,
                ),
                const SizedBox(height: 12),
                _recordTile(
                  'Highest burn',
                  workouts.isEmpty
                      ? '--'
                      : '${workouts.map((w) => w.calories).reduce((a, b) => a > b ? a : b)} kcal',
                  AppColors.secondary,
                ),
                const SizedBox(height: 12),
                _recordTile(
                  'Total sessions',
                  '${workouts.length}',
                  AppColors.primary,
                ),

                const SizedBox(height: 22),

                // ── History list ──────────────────────────────────────────
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('History', style: AppTextStyles.heading4),
                      const SizedBox(height: 14),
                      if (workoutProvider.isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(
                              color: AppColors.secondary,
                            ),
                          ),
                        )
                      else if (workouts.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: Text(
                              'No workouts recorded yet.',
                              style: AppTextStyles.body
                                  .copyWith(color: AppColors.white54),
                            ),
                          ),
                        )
                      else
                        ...workouts.take(10).map(
                              (w) => Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: _historyRow(w, prefs),
                              ),
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statTile(String title, String value, Color accent) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.caption.copyWith(color: AppColors.white54),
          ),
          const SizedBox(height: 18),
          Text(
            value,
            style: AppTextStyles.heading3.copyWith(color: accent),
          ),
        ],
      ),
    );
  }

  Widget _recordTile(String title, String value, Color color) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.emoji_events_rounded, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.body.copyWith(color: AppColors.white70),
            ),
          ),
          Text(
            value,
            style: AppTextStyles.heading4.copyWith(color: AppColors.white),
          ),
        ],
      ),
    );
  }

  Widget _historyRow(WorkoutModel workout, PreferencesProvider prefs) {
    final now = DateTime.now();
    final isToday = workout.createdAt.day == now.day &&
        workout.createdAt.month == now.month &&
        workout.createdAt.year == now.year;
    final isYesterday = workout.createdAt
        .isAfter(now.subtract(const Duration(days: 2))) && !isToday;

    String dateLabel;
    if (isToday) {
      dateLabel = 'Today';
    } else if (isYesterday) {
      dateLabel = 'Yesterday';
    } else {
      dateLabel = '${workout.createdAt.day}/${workout.createdAt.month}';
    }

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                workout.activityLabel,
                style: AppTextStyles.body.copyWith(color: AppColors.white),
              ),
              const SizedBox(height: 2),
              Text(
                '${prefs.formatDistance(workout.distance)} • ${workout.formattedDuration} • ${workout.calories} kcal',
                style: AppTextStyles.caption.copyWith(color: AppColors.white54),
              ),
            ],
          ),
        ),
        Text(
          dateLabel,
          style: AppTextStyles.caption.copyWith(color: AppColors.white38),
        ),
      ],
    );
  }
}

// ── Charts ─────────────────────────────────────────────────────────────────

/// Shows distance per day for the last 7 days.
class _WeeklyDistanceChart extends StatelessWidget {
  const _WeeklyDistanceChart({
    required this.workouts,
    required this.prefs,
  });

  final List<WorkoutModel> workouts;
  final PreferencesProvider prefs;

  @override
  Widget build(BuildContext context) {
    // Build a map of day-of-week → total distance (metres)
    final now = DateTime.now();
    final Map<int, double> dayDistance = {0: 0, 1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0};

    for (final w in workouts) {
      final diff = now.difference(w.createdAt).inDays;
      if (diff >= 0 && diff < 7) {
        final dayIndex = 6 - diff; // 6 = today, 0 = 6 days ago
        dayDistance[dayIndex] = (dayDistance[dayIndex] ?? 0) + w.distance;
      }
    }

    final spots = dayDistance.entries
        .map((e) {
          double val = e.value / 1000.0; // metres → km
          if (prefs.distanceUnit == DistanceUnit.miles) val *= 0.621371;
          return FlSpot(e.key.toDouble(), val);
        })
        .toList()
      ..sort((a, b) => a.x.compareTo(b.x));

    final maxY = spots.map((s) => s.y).fold(0.0, (a, b) => a > b ? a : b);

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          show: true,
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 26,
              getTitlesWidget: (value, meta) {
                final labels = _last7DayLabels();
                final idx = value.toInt();
                if (idx < 0 || idx >= labels.length) return const SizedBox();
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    labels[idx],
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.white54),
                  ),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
            ),
            barWidth: 4,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.28),
                  AppColors.primary.withOpacity(0.0),
                ],
              ),
            ),
          ),
        ],
        borderData: FlBorderData(show: false),
        minY: 0,
        maxY: maxY < 1 ? 5 : maxY * 1.2,
      ),
    );
  }

  List<String> _last7DayLabels() {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final now = DateTime.now();
    return List.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      return days[d.weekday - 1];
    });
  }
}

/// Shows calories per day for the last 7 days.
class _WeeklyCaloriesChart extends StatelessWidget {
  const _WeeklyCaloriesChart({required this.workouts});

  final List<WorkoutModel> workouts;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final Map<int, double> dayCalories = {0: 0, 1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0};

    for (final w in workouts) {
      final diff = now.difference(w.createdAt).inDays;
      if (diff >= 0 && diff < 7) {
        final dayIndex = 6 - diff;
        dayCalories[dayIndex] = (dayCalories[dayIndex] ?? 0) + w.calories;
      }
    }

    final maxY = dayCalories.values.fold(0.0, (a, b) => a > b ? a : b);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY < 100 ? 500 : maxY * 1.2,
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              getTitlesWidget: (value, meta) {
                final labels = _last7DayLabels();
                final idx = value.toInt();
                if (idx < 0 || idx >= labels.length) return const SizedBox();
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    labels[idx],
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.white54),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        barGroups: List.generate(7, (index) {
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                fromY: 0,
                toY: dayCalories[index] ?? 0,
                width: 16,
                borderRadius: BorderRadius.circular(10),
                gradient: const LinearGradient(
                  colors: [AppColors.secondary, AppColors.primary],
                ),
              ),
            ],
          );
        }),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  List<String> _last7DayLabels() {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final now = DateTime.now();
    return List.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      return days[d.weekday - 1];
    });
  }
}
