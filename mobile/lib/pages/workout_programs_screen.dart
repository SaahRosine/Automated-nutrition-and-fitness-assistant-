import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/constants/app_styles.dart';

class WorkoutProgramsScreen extends StatelessWidget {
  const WorkoutProgramsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Training plans', style: AppTextStyles.heading2(context)),
              const SizedBox(height: 8),
              Text(
                'Choose a program and stay consistent.',
                style: AppTextStyles.body(context).copyWith(
                  color: theme.colorScheme.onBackground.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 24),
              _programCard(context, 'Beginner Run', '4 weeks · 3 sessions/week', 0.58, theme.colorScheme.primary),
              const SizedBox(height: 16),
              _programCard(context, 'Interval Boost', '6 weeks · 4 sessions/week', 0.74, theme.colorScheme.secondary),
              const SizedBox(height: 16),
              _programCard(context, 'Endurance Peak', '8 weeks · 5 sessions/week', 0.42, theme.colorScheme.primary),
              const SizedBox(height: 24),
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Recommended today', style: AppTextStyles.heading4(context)),
                      const SizedBox(height: 16),
                      Text(
                        'Recovery run with tempo intervals to keep your legs fresh and the pace steady.',
                        style: AppTextStyles.body(context).copyWith(
                          color: theme.colorScheme.onBackground.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _miniStat(context, icon: Icons.timer_rounded, title: '27 min'),
                          const SizedBox(width: 16),
                          _miniStat(context, icon: Icons.speed_rounded, title: '5.4 km'),
                          const SizedBox(width: 16),
                          _miniStat(context, icon: Icons.local_fire_department_rounded, title: '320 kcal'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.go('/session'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.secondary,
                          minimumSize: const Size.fromHeight(48),
                        ),
                        child: const Text('Start program', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _programCard(BuildContext context, String title, String subtitle, double progress, Color accent) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(title, style: AppTextStyles.heading3(context))),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.fitness_center_rounded, color: theme.colorScheme.onBackground),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(subtitle, style: AppTextStyles.body(context).copyWith(
              color: theme.colorScheme.onBackground.withOpacity(0.7),
            )),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: theme.colorScheme.surfaceVariant,
              color: accent,
              minHeight: 8,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${(progress * 100).round()}% complete', style: AppTextStyles.caption(context)),
                Text('Next session', style: AppTextStyles.caption(context).copyWith(
                  color: theme.colorScheme.onBackground.withOpacity(0.7),
                )),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 650.ms);
  }

  Widget _miniStat(BuildContext context, {required IconData icon, required String title}) {
    final theme = Theme.of(context);
    return Expanded(
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: theme.colorScheme.secondary),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.body(context).copyWith(
                color: theme.colorScheme.onBackground.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
