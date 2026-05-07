import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/constants/app_styles.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class OnboardingStep {
  final String title;
  final String subtitle;
  final IconData icon;
  final String illustration;

  OnboardingStep({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.illustration,
  });
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _index = 0;

  final _steps = [
    OnboardingStep(
      title: 'Train smarter',
      subtitle: 'Stay motivated with tailored run plans and real-time coaching.',
      icon: Icons.track_changes_rounded,
      illustration: '🏃‍♂️',
    ),
    OnboardingStep(
      title: 'Track every run',
      subtitle: 'Live pace, distance and calories with premium route visualizations.',
      icon: Icons.map_rounded,
      illustration: '📍',
    ),
    OnboardingStep(
      title: 'Crush your goals',
      subtitle: 'Build momentum with streaks, badges and progress analytics.',
      icon: Icons.emoji_events_rounded,
      illustration: '🏅',
    ),
  ];

  void _goNext() {
    if (_index >= _steps.length - 1) {
      context.go('/login');
      return;
    }
    setState(() => _index += 1);
    _pageController.nextPage(duration: const Duration(milliseconds: 450), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 48),
                    Text('Welcome to Stride', style: AppTextStyles.heading2),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: const Text('Skip', style: TextStyle(color: AppColors.white54)),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _steps.length,
                  onPageChanged: (value) => setState(() => _index = value),
                  itemBuilder: (context, index) {
                    final step = _steps[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 180,
                            height: 180,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.primary, AppColors.secondary],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(32),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.24),
                                  blurRadius: 28,
                                  offset: const Offset(0, 18),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(step.illustration, style: const TextStyle(fontSize: 72)),
                            ),
                          ).animate().fadeIn(delay: 100.ms, duration: 900.ms),
                          const SizedBox(height: 32),
                          Text(step.title, style: AppTextStyles.heading1, textAlign: TextAlign.center),
                          const SizedBox(height: 18),
                          Text(
                            step.subtitle,
                            style: AppTextStyles.body.copyWith(color: AppColors.white70),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _steps.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 280),
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    width: _index == index ? 28 : 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _index == index ? AppColors.secondary : AppColors.white54,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 12),
                child: ElevatedButton(
                  onPressed: _goNext,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    backgroundColor: AppColors.secondary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  child: Text(
                    _index == _steps.length - 1 ? 'Let’s go' : 'Next',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 14),
            ],
          ),
        ),
      ),
    );
  }
}
