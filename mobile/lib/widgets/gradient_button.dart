import 'package:flutter/material.dart';
import 'package:mobile/core/constants/app_styles.dart';

class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.label,
    required this.isLoading,
    this.onTap,
    this.gradientColors,
    this.shadowColor,
  });

  final String label;
  final bool isLoading;
  final VoidCallback? onTap;
  final List<Color>? gradientColors;
  final Color? shadowColor;

  @override
  Widget build(BuildContext context) {
    final defaultGradient = AppColors.primaryGradient;
    final defaultShadow = AppColors.primary;
    
    final activeGradient = gradientColors ?? defaultGradient;
    final activeShadow = shadowColor ?? defaultShadow;

    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isLoading
                ? activeGradient.map((c) => c.withOpacity(0.6)).toList()
                : activeGradient,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: isLoading
              ? []
              : [
                  BoxShadow(
                    color: activeShadow.withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                  ),
                )
              : Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
        ),
      ),
    );
  }
}
