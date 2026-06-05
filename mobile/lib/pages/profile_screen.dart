import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:mobile/core/constants/app_styles.dart';
import 'package:mobile/providers/user_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(Icons.person_rounded, color: Colors.white, size: 36),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(userProvider.email ?? 'alex@example.com', style: AppTextStyles.heading3(context)),
                        const SizedBox(height: 8),
                        Text(
                          'Runner • 34 yrs old',
                          style: AppTextStyles.body(context).copyWith(
                            color: theme.colorScheme.onBackground.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text('12', style: AppTextStyles.heading3(context).copyWith(color: theme.colorScheme.secondary)),
                        Text('badges', style: AppTextStyles.caption(context)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      _goalTile(context, 'Weekly goal', '32 km'),
                      const SizedBox(width: 16),
                      _goalTile(context, 'Active time', '4h 20m'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('Achievements', style: AppTextStyles.heading3(context)),
              const SizedBox(height: 16),
              Row(
                children: [
                  _badge(context, 'Streak', Icons.whatshot_rounded),
                  const SizedBox(width: 16),
                  _badge(context, 'Speed', Icons.speed_rounded),
                  const SizedBox(width: 16),
                  _badge(context, 'Consistency', Icons.calendar_today_rounded),
                ],
              ),
              const SizedBox(height: 24),
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Settings', style: AppTextStyles.heading4(context)),
                      const SizedBox(height: 16),
                      _optionRow(context, Icons.notifications_rounded, 'Notifications'),
                      const SizedBox(height: 16),
                      _optionRow(context, Icons.settings_rounded, 'Settings', onTap: () => context.push('/settings')),
                      const SizedBox(height: 16),
                      _optionRow(context, Icons.logout_rounded, 'Sign out', onTap: () => context.read<UserProvider>().logout()),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('Your streak', style: AppTextStyles.heading3(context)),
              const SizedBox(height: 16),
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _progressBadge(context, '7', 'Days'),
                          const SizedBox(width: 16),
                          _progressBadge(context, '3', 'Runs'),
                          const SizedBox(width: 16),
                          _progressBadge(context, '2', 'Goals'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text('Current goal', style: AppTextStyles.caption(context)),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: 0.68,
                        backgroundColor: theme.colorScheme.surfaceVariant,
                        color: theme.colorScheme.secondary,
                        minHeight: 8,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Stay consistent for 4 more days to unlock the next tier.',
                        style: AppTextStyles.body(context).copyWith(
                          color: theme.colorScheme.onBackground.withOpacity(0.7),
                        ),
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

  Widget _goalTile(BuildContext context, String title, String value) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.caption(context)),
          const SizedBox(height: 8),
          Text(value, style: AppTextStyles.heading3(context)),
        ],
      ),
    );
  }

  Widget _badge(BuildContext context, String label, IconData icon) {
    final theme = Theme.of(context);
    return Expanded(
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: theme.colorScheme.secondary),
              ),
              const SizedBox(height: 12),
              Text(label, style: AppTextStyles.body(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _optionRow(BuildContext context, IconData icon, String label, {VoidCallback? onTap}) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: theme.colorScheme.onBackground),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(label, style: AppTextStyles.body(context))),
            Icon(
              Icons.chevron_right_rounded,
              color: theme.colorScheme.onBackground.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _progressBadge(BuildContext context, String value, String label) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(value, style: AppTextStyles.heading3(context)),
            const SizedBox(height: 8),
            Text(label, style: AppTextStyles.caption(context)),
          ],
        ),
      ),
    );
  }
}
