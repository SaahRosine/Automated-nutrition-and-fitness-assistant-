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
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: [accent.withOpacity(0.22), theme.colorScheme.surfaceVariant.withOpacity(0.3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
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
          Text(value, style: AppTextStyles.heading3(context)),
          const SizedBox(height: 6),
          Text(label, style: AppTextStyles.caption(context).copyWith(color: theme.colorScheme.onBackground.withOpacity(0.5))),
        ],
      ),
    );
  }
}
