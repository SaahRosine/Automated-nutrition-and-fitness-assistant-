import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/constants/app_styles.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 1800), () {
      if (mounted) context.go('/onboarding');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.28),
                    blurRadius: 28,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.directions_run_rounded,
                  size: 58,
                  color: AppColors.white,
                ),
              ),
            ).animate().scale(begin: Offset(0.8, 0.8), end: Offset(1.0, 1.0), curve: Curves.elasticOut, duration: 900.ms),
            const SizedBox(height: 28),
            Column(
              children: [
                Text('Stride', style: AppTextStyles.heading1.copyWith(fontSize: 36)).animate().fadeIn(duration: 900.ms),
                const SizedBox(height: 8),
                Text(
                  'A better run starts here',
                  style: AppTextStyles.body.copyWith(color: AppColors.white54),
                ).animate().fadeIn(delay: 250.ms, duration: 900.ms),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
