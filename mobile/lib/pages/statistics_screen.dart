import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mobile/core/constants/app_styles.dart';
import 'package:mobile/widgets/glass_card.dart';
import 'package:mobile/widgets/stat_chart.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

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
              Text('Statistics', style: AppTextStyles.heading2),
              const SizedBox(height: 8),
              Text('Track your improvement with clear analytics.', style: AppTextStyles.body.copyWith(color: AppColors.white70)),
              const SizedBox(height: 24),
              GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Weekly pace', style: AppTextStyles.heading4),
                    const SizedBox(height: 16),
                    SizedBox(height: 210, child: const PerformanceLineChart()),
                  ],
                ),
              ).animate().fadeIn(duration: 700.ms),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: _statTile('Longest run', '12.6 km', AppColors.primary)),
                  const SizedBox(width: 14),
                  Expanded(child: _statTile('Best pace', '4’17"', AppColors.secondary)),
                ],
              ),
              const SizedBox(height: 20),
              GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Calories trend', style: AppTextStyles.heading4),
                    const SizedBox(height: 16),
                    SizedBox(height: 210, child: const EnergyBarChart()),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Text('Personal records', style: AppTextStyles.heading3),
              const SizedBox(height: 14),
              _recordTile('Fastest 5K', '21:48', AppColors.primary),
              const SizedBox(height: 12),
              _recordTile('Highest burn', '688 kcal', AppColors.secondary),
              const SizedBox(height: 22),
              GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('History', style: AppTextStyles.heading4),
                    const SizedBox(height: 14),
                    _historyRow('Morning jog', '3.9 km • 21 min', 'Today'),
                    const SizedBox(height: 14),
                    _historyRow('Park tempo', '7.1 km • 38 min', 'Yesterday'),
                  ],
                ),
              ),
            ],
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
          Text(title, style: AppTextStyles.caption.copyWith(color: AppColors.white54)),
          const SizedBox(height: 18),
          Text(value, style: AppTextStyles.heading3.copyWith(color: accent)),
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
            decoration: BoxDecoration(color: color.withOpacity(0.18), borderRadius: BorderRadius.circular(14)),
            child: Icon(Icons.emoji_events_rounded, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(child: Text(title, style: AppTextStyles.body.copyWith(color: AppColors.white70))),
          Text(value, style: AppTextStyles.heading4.copyWith(color: AppColors.white)),
        ],
      ),
    );
  }

  Widget _historyRow(String title, String subtitle, String date) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: AppTextStyles.body.copyWith(color: AppColors.white)),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(subtitle, style: AppTextStyles.caption.copyWith(color: AppColors.white54)),
            const SizedBox(height: 2),
            Text(date, style: AppTextStyles.caption.copyWith(color: AppColors.white38)),
          ],
        ),
      ],
    );
  }
}
