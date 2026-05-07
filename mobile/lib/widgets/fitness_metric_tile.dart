import 'package:flutter/material.dart';
import 'package:mobile/core/constants/app_styles.dart';

class FitnessMetricTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color accent;

  const FitnessMetricTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: [accent.withOpacity(0.22), AppColors.white10],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: AppColors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(color: accent.withOpacity(0.18), borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: accent, size: 24),
          ),
          const SizedBox(height: 16),
          Text(value, style: AppTextStyles.heading3),
          const SizedBox(height: 6),
          Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.white54)),
        ],
      ),
    );
  }
}
