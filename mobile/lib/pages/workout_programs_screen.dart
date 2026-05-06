import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mobile/core/constants/app_styles.dart';
import 'package:mobile/widgets/glass_card.dart';

class WorkoutProgramsScreen extends StatelessWidget {
  const WorkoutProgramsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Training plans', style: AppTextStyles.heading2),
              const SizedBox(height: 8),
              Text('Choose a program and stay consistent.', style: AppTextStyles.body.copyWith(color: AppColors.white70)),
              const SizedBox(height: 24),
              _programCard('Beginner Run', '4 weeks · 3 sessions/week', 0.58, AppColors.primary),
              const SizedBox(height: 16),
              _programCard('Interval Boost', '6 weeks · 4 sessions/week', 0.74, AppColors.secondary),
              const SizedBox(height: 16),
              _programCard('Endurance Peak', '8 weeks · 5 sessions/week', 0.42, AppColors.primary),
              const SizedBox(height: 28),
              GlassCard(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Recommended today', style: AppTextStyles.heading4),
                      const SizedBox(height: 14),
                      Text('Recovery run with tempo intervals to keep your legs fresh and the pace steady.', style: AppTextStyles.body.copyWith(color: AppColors.white70)),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          _miniStat(icon: Icons.timer_rounded, title: '27 min'),
                          const SizedBox(width: 14),
                          _miniStat(icon: Icons.speed_rounded, title: '5.4 km'),
                          const SizedBox(width: 14),
                          _miniStat(icon: Icons.local_fire_department_rounded, title: '320 kcal'),
                        ],
                      ),
                      const SizedBox(height: 18),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          minimumSize: const Size.fromHeight(52),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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

  Widget _programCard(String title, String subtitle, double progress, Color accent) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: AppTextStyles.heading3)),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: accent.withOpacity(0.18), borderRadius: BorderRadius.circular(16)),
                child: const Icon(Icons.fitness_center_rounded, color: AppColors.white),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(subtitle, style: AppTextStyles.body.copyWith(color: AppColors.white70)),
          const SizedBox(height: 18),
          LinearProgressIndicator(value: progress, backgroundColor: AppColors.white12, color: accent, minHeight: 9),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${(progress * 100).round()}% complete', style: AppTextStyles.caption.copyWith(color: AppColors.white54)),
              Text('Next session', style: AppTextStyles.caption.copyWith(color: AppColors.white70)),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 650.ms);
  }

  Widget _miniStat({required IconData icon, required String title}) {
    return Expanded(
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: AppColors.white10, borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, size: 20, color: AppColors.secondary),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(title, style: AppTextStyles.body.copyWith(color: AppColors.white70))),
        ],
      ),
    );
  }
}
