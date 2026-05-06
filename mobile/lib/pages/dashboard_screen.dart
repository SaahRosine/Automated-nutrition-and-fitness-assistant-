import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/constants/app_styles.dart';
import 'package:mobile/widgets/fitness_metric_tile.dart';
import 'package:mobile/widgets/glass_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 96),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              _buildDailySummary(context),
              const SizedBox(height: 22),
              _buildQuickActions(context),
              const SizedBox(height: 24),
              _buildRecentWorkouts(context),
              const SizedBox(height: 24),
              _buildProgressCards(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Good evening, Alex', style: AppTextStyles.heading2),
              const SizedBox(height: 8),
              Text('Your run streak is 6 days strong.', style: AppTextStyles.body.copyWith(color: AppColors.white70)),
            ],
          ),
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [AppColors.primary, AppColors.secondary])),
            ),
            const Icon(Icons.bar_chart_rounded, color: AppColors.white, size: 26),
          ],
        ).animate().scale(delay: 120.ms, duration: 750.ms),
      ],
    );
  }

  Widget _buildDailySummary(BuildContext context) {
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
                    Text('Today', style: AppTextStyles.label?.copyWith(color: AppColors.white54)),
                    const SizedBox(height: 8),
                    Text('Daily performance', style: AppTextStyles.heading3),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppColors.white10, borderRadius: BorderRadius.circular(14)),
                child: const Icon(Icons.star_rounded, color: AppColors.secondary),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: FitnessMetricTile(label: 'Steps', value: '9,342', icon: Icons.directions_walk_rounded, accent: AppColors.primary)),
              const SizedBox(width: 14),
              Expanded(child: FitnessMetricTile(label: 'Calories', value: '523 kcal', icon: Icons.local_fire_department_rounded, accent: AppColors.secondary)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: FitnessMetricTile(label: 'Distance', value: '6.2 km', icon: Icons.place_rounded, accent: AppColors.primary)),
              const SizedBox(width: 14),
              Expanded(child: FitnessMetricTile(label: 'Active', value: '47 min', icon: Icons.timer_rounded, accent: AppColors.secondary)),
            ],
          ),
          const SizedBox(height: 26),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Goal progress', style: AppTextStyles.label?.copyWith(color: AppColors.white54)),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(value: 0.72, color: AppColors.secondary, backgroundColor: AppColors.white12, minHeight: 8),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('72%', style: AppTextStyles.heading3),
                  Text('weekly target', style: AppTextStyles.caption.copyWith(color: AppColors.white54)),
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
            _actionTile(context, 'Run now', Icons.run_circle, AppColors.primary, '/session'),
            const SizedBox(width: 14),
            _actionTile(context, 'Programs', Icons.auto_graph_rounded, AppColors.secondary, '/programs'),
            const SizedBox(width: 14),
            _actionTile(context, 'Analytics', Icons.show_chart_rounded, AppColors.white10, '/stats'),
          ],
        ),
      ],
    );
  }

  Widget _actionTile(BuildContext context, String label, IconData icon, Color color, String route) {
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
                decoration: BoxDecoration(color: color.withOpacity(0.18), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(height: 16),
              Text(label, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentWorkouts(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent workouts', style: AppTextStyles.heading3),
            Text('See all', style: AppTextStyles.caption.copyWith(color: AppColors.secondary)),
          ],
        ),
        const SizedBox(height: 16),
        Column(
          children: [
            _activityRow('Morning run', '5.1 km • 34 min', 'Today', AppColors.primary),
            const SizedBox(height: 14),
            _activityRow('Hill sprint', '4.2 km • 28 min', 'Yesterday', AppColors.secondary),
          ],
        ),
      ],
    );
  }

  Widget _activityRow(String title, String description, String date, Color accent) {
    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(color: accent.withOpacity(0.18), borderRadius: BorderRadius.circular(18)),
            child: Icon(Icons.directions_run_rounded, color: accent, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.heading4),
                const SizedBox(height: 6),
                Text(description, style: AppTextStyles.caption.copyWith(color: AppColors.white54)),
              ],
            ),
          ),
          Text(date, style: AppTextStyles.caption.copyWith(color: AppColors.white54)),
        ],
      ),
    );
  }

  Widget _buildProgressCards(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Progress summary', style: AppTextStyles.heading3),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _summaryCard('Weekly distance', '42.3 km', '18% above goal', AppColors.primary)),
            const SizedBox(width: 14),
            Expanded(child: _summaryCard('Calories burned', '3,248 kcal', 'Steady pace', AppColors.secondary)),
          ],
        ),
      ],
    );
  }

  Widget _summaryCard(String title, String value, String subtitle, Color accent) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(color: accent.withOpacity(0.18), borderRadius: BorderRadius.circular(16)),
            child: Icon(Icons.flash_on_rounded, color: accent),
          ),
          const SizedBox(height: 20),
          Text(value, style: AppTextStyles.heading3),
          const SizedBox(height: 10),
          Text(title, style: AppTextStyles.body.copyWith(color: AppColors.white70)),
          const SizedBox(height: 14),
          Text(subtitle, style: AppTextStyles.caption.copyWith(color: AppColors.white54)),
        ],
      ),
    );
  }
}
