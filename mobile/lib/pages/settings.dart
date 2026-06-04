import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:mobile/core/constants/app_styles.dart';
import 'package:mobile/providers/preferences_provider.dart';
import 'package:mobile/providers/theme_provider.dart';
import 'package:mobile/providers/user_provider.dart';
import 'package:mobile/widgets/section_title.dart';
import 'package:mobile/widgets/settings_text_field.dart';
import 'package:mobile/widgets/vibrant_button.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with WidgetsBindingObserver {
  // Profile update controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _newEmailController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _weightUpdateController = TextEditingController();

  bool _isUpdateExpanded = false;
  bool _isWeightExpanded = false;
  bool _canUpdate = false;

  // Permission states
  PermissionStatus _locationStatus = PermissionStatus.denied;
  PermissionStatus _activityStatus = PermissionStatus.denied;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _emailController.addListener(_checkCanUpdate);
    _passwordController.addListener(_checkCanUpdate);
    _newEmailController.addListener(_checkCanUpdate);
    _newPasswordController.addListener(_checkCanUpdate);
    _loadPermissionStatuses();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Re-check permissions when user returns from system settings
    if (state == AppLifecycleState.resumed) {
      _loadPermissionStatuses();
    }
  }

  Future<void> _loadPermissionStatuses() async {
    final loc = await Permission.location.status;
    final act = await Permission.activityRecognition.status;
    if (mounted) {
      setState(() {
        _locationStatus = loc;
        _activityStatus = act;
      });
    }
  }

  void _checkCanUpdate() {
    final hasCredentials = _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty;
    final hasNewData = _newEmailController.text.isNotEmpty ||
        _newPasswordController.text.isNotEmpty;
    if (_canUpdate != (hasCredentials && hasNewData)) {
      setState(() => _canUpdate = hasCredentials && hasNewData);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _emailController.dispose();
    _passwordController.dispose();
    _newEmailController.dispose();
    _newPasswordController.dispose();
    _weightUpdateController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.warning : AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleUpdate() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final newEmail = _newEmailController.text.trim();
    final newPassword = _newPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar('Current email and password are required', isError: true);
      return;
    }
    if (newEmail.isEmpty && newPassword.isEmpty) {
      _showSnackBar('Provide a new email or password to update', isError: true);
      return;
    }

    final success = await context.read<UserProvider>().updateProfile(
          email: email,
          password: password,
          newEmail: newEmail.isNotEmpty ? newEmail : null,
          newPassword: newPassword.isNotEmpty ? newPassword : null,
        );

    if (success) {
      _showSnackBar('Profile updated successfully!');
      _newEmailController.clear();
      _newPasswordController.clear();
      _passwordController.clear();
    } else {
      _showSnackBar(
        context.read<UserProvider>().errorMessage ?? 'Update failed',
        isError: true,
      );
    }
  }

  Future<void> _handleWeightUpdate() async {
    final weightStr = _weightUpdateController.text.trim();
    if (weightStr.isEmpty) {
      _showSnackBar('Please enter a weight', isError: true);
      return;
    }
    final weight = double.tryParse(weightStr);
    if (weight == null || weight <= 0) {
      _showSnackBar('Please enter a valid weight', isError: true);
      return;
    }

    final success = await context.read<UserProvider>().updateWeight(weight);
    if (success) {
      _showSnackBar('Weight updated successfully!');
      _weightUpdateController.clear();
      setState(() => _isWeightExpanded = false);
    } else {
      _showSnackBar(
        context.read<UserProvider>().errorMessage ?? 'Update failed',
        isError: true,
      );
    }
  }

  Future<void> _requestPermission(Permission permission) async {
    final status = await permission.request();
    if (status.isPermanentlyDenied) {
      // Guide user to system settings
      await openAppSettings();
    }
    await _loadPermissionStatuses();
  }

  Future<void> _confirmDelete() async {
    final userProvider = context.read<UserProvider>();
    final themeProvider = context.read<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    final deleteEmailController = TextEditingController();
    final deletePasswordController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final isFormValid = deleteEmailController.text.isNotEmpty &&
              deletePasswordController.text.isNotEmpty;

          return AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: AppColors.warning),
                SizedBox(width: 10),
                Text(
                  'Delete Account',
                  style: TextStyle(color: AppColors.warning),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'This action is permanent and cannot be undone. All your data will be lost.',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Enter credentials to confirm:',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.greyText,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: deleteEmailController,
                    onChanged: (_) => setDialogState(() {}),
                    decoration: InputDecoration(
                      labelText: 'Current Email',
                      prefixIcon: const Icon(Icons.email_outlined, size: 20),
                      filled: true,
                      fillColor: isDark
                          ? AppColors.darkSurfaceAlt
                          : Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: deletePasswordController,
                    obscureText: true,
                    onChanged: (_) => setDialogState(() {}),
                    decoration: InputDecoration(
                      labelText: 'Current Password',
                      prefixIcon: const Icon(Icons.lock_outline, size: 20),
                      filled: true,
                      fillColor: isDark
                          ? AppColors.darkSurfaceAlt
                          : Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('CANCEL'),
              ),
              ElevatedButton(
                onPressed: !isFormValid
                    ? null
                    : () async {
                        final success = await userProvider.deleteAccount(
                          email: deleteEmailController.text.trim(),
                          password: deletePasswordController.text.trim(),
                        );
                        if (mounted) Navigator.pop(context, success);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warning,
                  foregroundColor: AppColors.white,
                  disabledBackgroundColor: AppColors.greyText,
                ),
                child: const Text('DELETE PERMANENTLY'),
              ),
            ],
          );
        },
      ),
    );

    deleteEmailController.dispose();
    deletePasswordController.dispose();

    if (result == true && mounted) {
      await SystemNavigator.pop();
    } else if (result == false && mounted) {
      _showSnackBar(
        userProvider.errorMessage ?? 'Deletion failed. Check credentials.',
        isError: true,
      );
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final userProvider = context.watch<UserProvider>();
    final prefs = context.watch<PreferencesProvider>();
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        leading: BackButton(onPressed: () => Navigator.maybePop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Profile card ───────────────────────────────────────────────
            _buildProfileCard(userProvider, isDark),
            const SizedBox(height: 32),

            // ── Appearance ─────────────────────────────────────────────────
            SectionTitle(title: 'Appearance', icon: Icons.palette_outlined),
            Card(
              elevation: 0,
              color: isDark ? AppColors.darkSurfaceAlt : Colors.grey[100],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: SwitchListTile(
                title: const Text('Dark Mode'),
                subtitle: Text(isDark ? 'Sleek & Power Saving' : 'Clean & Bright'),
                value: isDark,
                onChanged: (val) => themeProvider.toggleTheme(val),
                secondary: Icon(
                  isDark ? Icons.dark_mode : Icons.light_mode,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // ── Units ──────────────────────────────────────────────────────
            SectionTitle(title: 'Units', icon: Icons.straighten_rounded),
            Card(
              elevation: 0,
              color: isDark ? AppColors.darkSurfaceAlt : Colors.grey[100],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  // Distance unit
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.place_rounded,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Distance',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        _unitToggle(
                          options: const ['km', 'mi'],
                          selected: prefs.distanceUnit == DistanceUnit.km ? 0 : 1,
                          onChanged: (i) => prefs.setDistanceUnit(
                            i == 0 ? DistanceUnit.km : DistanceUnit.miles,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(indent: 16, endIndent: 16, height: 1),
                  // Weight unit
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                    child: Row(
                      children: [
                        Icon(
                          Icons.monitor_weight_outlined,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Weight',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        _unitToggle(
                          options: const ['kg', 'lbs'],
                          selected: prefs.weightUnit == WeightUnit.kg ? 0 : 1,
                          onChanged: (i) => prefs.setWeightUnit(
                            i == 0 ? WeightUnit.kg : WeightUnit.lbs,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ── Notifications ──────────────────────────────────────────────
            SectionTitle(
              title: 'Notifications',
              icon: Icons.notifications_outlined,
            ),
            Card(
              elevation: 0,
              color: isDark ? AppColors.darkSurfaceAlt : Colors.grey[100],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: SwitchListTile(
                title: const Text('Workout reminders'),
                subtitle: const Text('Get notified to stay on track'),
                value: prefs.notificationsEnabled,
                onChanged: (val) => prefs.setNotificationsEnabled(val),
                secondary: Icon(
                  prefs.notificationsEnabled
                      ? Icons.notifications_active_rounded
                      : Icons.notifications_off_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // ── Permissions ────────────────────────────────────────────────
            SectionTitle(
              title: 'Permissions',
              icon: Icons.security_rounded,
            ),
            const Text(
              'Required for GPS tracking and step counting.',
              style: TextStyle(fontSize: 12, color: AppColors.greyText),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              color: isDark ? AppColors.darkSurfaceAlt : Colors.grey[100],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _permissionTile(
                    icon: Icons.location_on_rounded,
                    title: 'Location',
                    subtitle: 'GPS tracking during workouts',
                    status: _locationStatus,
                    onRequest: () => _requestPermission(Permission.location),
                  ),
                  const Divider(indent: 16, endIndent: 16, height: 1),
                  _permissionTile(
                    icon: Icons.directions_walk_rounded,
                    title: 'Activity Recognition',
                    subtitle: 'Step counting and motion detection',
                    status: _activityStatus,
                    onRequest: () =>
                        _requestPermission(Permission.activityRecognition),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ── Health & Fitness ───────────────────────────────────────────
            SectionTitle(
              title: 'Health & Fitness',
              icon: Icons.fitness_center,
            ),
            Card(
              elevation: 0,
              color: isDark ? AppColors.darkSurfaceAlt : Colors.grey[100],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Current Weight'),
                    trailing: Text(
                      prefs.formatWeight(userProvider.weight ?? 0),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    onTap: () =>
                        setState(() => _isWeightExpanded = !_isWeightExpanded),
                    leading: Icon(
                      Icons.monitor_weight_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    child: _isWeightExpanded
                        ? Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                SettingsTextField(
                                  controller: _weightUpdateController,
                                  label:
                                      'New Weight (${prefs.weightUnitLabel})',
                                  icon: Icons.add_chart_outlined,
                                ),
                                const SizedBox(height: 16),
                                VibrantButton(
                                  label: 'UPDATE WEIGHT',
                                  onPressed: userProvider.isLoading
                                      ? null
                                      : _handleWeightUpdate,
                                  isVibrant: true,
                                  isLoading: userProvider.isLoading,
                                ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ── Update Profile ─────────────────────────────────────────────
            SectionTitle(
              title: 'Update Profile',
              icon: Icons.person_outline,
            ),
            const Text(
              'Security verification required for all changes.',
              style: TextStyle(fontSize: 12, color: AppColors.greyText),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () =>
                  setState(() => _isUpdateExpanded = !_isUpdateExpanded),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceAlt : Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _isUpdateExpanded
                        ? Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.5)
                        : AppColors.transparent,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isUpdateExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _isUpdateExpanded
                          ? 'Close Edit Menu'
                          : 'Configure Changes',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: _isUpdateExpanded
                  ? Column(
                      children: [
                        const SizedBox(height: 20),
                        SettingsTextField(
                          controller: _emailController,
                          label: 'Current Email',
                          icon: Icons.email_outlined,
                        ),
                        const SizedBox(height: 12),
                        SettingsTextField(
                          controller: _passwordController,
                          label: 'Current Password',
                          icon: Icons.lock_outline,
                          isPassword: true,
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Divider(height: 1),
                        ),
                        SettingsTextField(
                          controller: _newEmailController,
                          label: 'New Email (Optional)',
                          icon: Icons.alternate_email,
                        ),
                        const SizedBox(height: 12),
                        SettingsTextField(
                          controller: _newPasswordController,
                          label: 'New Password (Optional)',
                          icon: Icons.vpn_key_outlined,
                          isPassword: true,
                        ),
                        const SizedBox(height: 24),
                        VibrantButton(
                          label: 'SAVE CHANGES',
                          onPressed: userProvider.isLoading || !_canUpdate
                              ? null
                              : _handleUpdate,
                          isVibrant: _canUpdate,
                          isLoading: userProvider.isLoading,
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
            const SizedBox(height: 32),

            // ── Account ────────────────────────────────────────────────────
            SectionTitle(
              title: 'Account',
              icon: Icons.manage_accounts_outlined,
            ),
            Card(
              elevation: 0,
              color: isDark ? AppColors.darkSurfaceAlt : AppColors.lightSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                leading: Icon(
                  Icons.logout,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text(
                  'Log Out',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  await context.read<UserProvider>().logout();
                  if (context.mounted) {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  }
                },
              ),
            ),
            const SizedBox(height: 32),

            // ── Danger Zone ────────────────────────────────────────────────
            SectionTitle(
              title: 'Danger Zone',
              icon: Icons.warning_amber_rounded,
              color: AppColors.warning,
            ),
            Card(
              elevation: 0,
              color: AppColors.warningLight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppColors.warning, width: 0.5),
              ),
              child: ListTile(
                title: const Text(
                  'Delete Account',
                  style: TextStyle(color: AppColors.warning),
                ),
                subtitle: const Text('All data will be permanently removed'),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: AppColors.warning,
                ),
                onTap: _confirmDelete,
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Widget _buildProfileCard(UserProvider userProvider, bool isDark) {
    return Card(
      elevation: 0,
      color: isDark ? AppColors.darkSurfaceAlt : Colors.grey[100],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.person_rounded,
                color: AppColors.white,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userProvider.email ?? 'User',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Athlete',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _unitToggle({
    required List<String> options,
    required int selected,
    required ValueChanged<int> onChanged,
  }) {
    return ToggleButtons(
      isSelected: List.generate(options.length, (i) => i == selected),
      onPressed: onChanged,
      borderRadius: BorderRadius.circular(10),
      constraints: const BoxConstraints(minWidth: 48, minHeight: 36),
      children: options
          .map(
            (o) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(o, style: const TextStyle(fontSize: 13)),
            ),
          )
          .toList(),
    );
  }

  Widget _permissionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required PermissionStatus status,
    required VoidCallback onRequest,
  }) {
    final isGranted =
        status == PermissionStatus.granted || status == PermissionStatus.limited;
    final isPermanentlyDenied = status == PermissionStatus.permanentlyDenied;

    Color statusColor;
    String statusLabel;
    if (isGranted) {
      statusColor = AppColors.success;
      statusLabel = 'Granted';
    } else if (isPermanentlyDenied) {
      statusColor = AppColors.warning;
      statusLabel = 'Open Settings';
    } else {
      statusColor = Colors.grey;
      statusLabel = 'Request';
    }

    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: GestureDetector(
        onTap: isGranted ? null : onRequest,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: statusColor.withOpacity(0.4)),
          ),
          child: Text(
            statusLabel,
            style: TextStyle(
              color: statusColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
