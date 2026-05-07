import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/core/constants/app_styles.dart';
import 'package:mobile/providers/theme_provider.dart';
import 'package:mobile/providers/user_provider.dart';
import 'package:mobile/widgets/glass_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final userProvider = context.watch<UserProvider>();

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Icon(Icons.person_rounded, color: AppColors.white, size: 34),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(userProvider.email ?? 'alex@example.com', style: AppTextStyles.heading3),
                        const SizedBox(height: 6),
                        Text('Runner • 34 yrs old', style: AppTextStyles.body.copyWith(color: AppColors.white70)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(color: AppColors.white10, borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      children: [
                        Text('12', style: AppTextStyles.heading3.copyWith(color: AppColors.secondary)),
                        Text('badges', style: AppTextStyles.caption.copyWith(color: AppColors.white54)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              GlassCard(
                padding: const EdgeInsets.all(22),
                child: Row(
                  children: [
                    _goalTile('Weekly goal', '32 km'),
                    const SizedBox(width: 12),
                    _goalTile('Active time', '4h 20m'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text('Achievements', style: AppTextStyles.heading3),
              const SizedBox(height: 14),
              Row(
                children: [
                  _badge('Streak', Icons.whatshot_rounded),
                  const SizedBox(width: 12),
                  _badge('Speed', Icons.speed_rounded),
                  const SizedBox(width: 12),
                  _badge('Consistency', Icons.calendar_today_rounded),
                ],
              ),
              const SizedBox(height: 24),
              GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Settings', style: AppTextStyles.heading4),
                        Switch(
                          value: themeProvider.isDarkMode,
                          activeColor: AppColors.secondary,
                          onChanged: (value) => context.read<ThemeProvider>().toggleTheme(value),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _optionRow(Icons.notifications_rounded, 'Notifications'),
                    const SizedBox(height: 14),
                    _optionRow(Icons.lock_outline_rounded, 'Privacy'),
                    const SizedBox(height: 14),
                    _optionRow(Icons.logout_rounded, 'Sign out', onTap: () => context.read<UserProvider>().logout()),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text('Your streak', style: AppTextStyles.heading3),
              const SizedBox(height: 14),
              GlassCard(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _progressBadge('7', 'Days'),
                        const SizedBox(width: 14),
                        _progressBadge('3', 'Runs'),
                        const SizedBox(width: 14),
                        _progressBadge('2', 'Goals'),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text('Current goal', style: AppTextStyles.caption.copyWith(color: AppColors.white54)),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(value: 0.68, backgroundColor: AppColors.white12, color: AppColors.secondary, minHeight: 10),
                    const SizedBox(height: 12),
                    Text('Stay consistent for 4 more days to unlock the next tier.', style: AppTextStyles.body.copyWith(color: AppColors.white70)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _goalTile(String title, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.caption.copyWith(color: AppColors.white54)),
          const SizedBox(height: 10),
          Text(value, style: AppTextStyles.heading3),
        ],
      ),
    );
  }

  Widget _badge(String label, IconData icon) {
    return Expanded(
      child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        child: Column(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(color: AppColors.white10, borderRadius: BorderRadius.circular(16)),
              child: Icon(icon, color: AppColors.secondary),
            ),
            const SizedBox(height: 12),
            Text(label, style: AppTextStyles.body.copyWith(color: AppColors.white)),
          ],
        ),
      ),
    );
  }

  Widget _optionRow(IconData icon, String label, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: AppColors.white10, borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: AppColors.white),
            ),
            const SizedBox(width: 14),
            Expanded(child: Text(label, style: AppTextStyles.body.copyWith(color: AppColors.white))),
            const Icon(Icons.chevron_right_rounded, color: AppColors.white54),
          ],
        ),
      ),
    );
  }

  Widget _progressBadge(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
        decoration: BoxDecoration(color: AppColors.white10, borderRadius: BorderRadius.circular(18)),
        child: Column(
          children: [
            Text(value, style: AppTextStyles.heading3),
            const SizedBox(height: 5),
            Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.white54)),
          ],
        ),
      ),
    );
  }
}
