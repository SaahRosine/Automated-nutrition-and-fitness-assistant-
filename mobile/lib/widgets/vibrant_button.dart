import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/providers/theme_provider.dart';
import 'package:mobile/core/constants/app_styles.dart';

class VibrantButton extends StatelessWidget {
  const VibrantButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.isVibrant,
    required this.isLoading,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isVibrant;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: isVibrant
            ? [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                )
              ]
            : [],
        gradient: isVibrant
            ? const LinearGradient(
                colors: AppColors.primaryGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: !isVibrant
            ? (context.watch<ThemeProvider>().isDarkMode ? AppColors.disabledBackground : AppColors.lightBorder)
            : null,
      ),
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2),
                  )
                : Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isVibrant ? AppColors.white : AppColors.greyTextDark,
                      letterSpacing: 1.1,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
