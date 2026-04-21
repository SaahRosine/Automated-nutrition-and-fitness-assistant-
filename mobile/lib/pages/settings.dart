import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/providers/user_provider.dart';
import 'package:mobile/providers/theme_provider.dart';
import 'package:flutter/services.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _newEmailController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _weightUpdateController = TextEditingController();

  bool _isUpdateExpanded = false;
  bool _isWeightExpanded = false;
  bool _canUpdate = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_checkCanUpdate);
    _passwordController.addListener(_checkCanUpdate);
    _newEmailController.addListener(_checkCanUpdate);
    _newPasswordController.addListener(_checkCanUpdate);
  }

  void _checkCanUpdate() {
    final hasCredentials =
        _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty;
    final hasNewData =
        _newEmailController.text.isNotEmpty || _newPasswordController.text.isNotEmpty;
    if (_canUpdate != (hasCredentials && hasNewData)) {
      setState(() {
        _canUpdate = hasCredentials && hasNewData;
      });
    }
  }

  @override
  void dispose() {
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
        backgroundColor: isError ? Colors.redAccent : Colors.green,
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
      _showSnackBar(context.read<UserProvider>().errorMessage ?? 'Update failed',
          isError: true);
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
      _showSnackBar(context.read<UserProvider>().errorMessage ?? 'Update failed',
          isError: true);
    }
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
          final isFormValid =
              deleteEmailController.text.isNotEmpty && deletePasswordController.text.isNotEmpty;

          return AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
                SizedBox(width: 10),
                Text('Delete Account', style: TextStyle(color: Colors.redAccent)),
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
                  const Text('Enter credentials to confirm:',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: deleteEmailController,
                    onChanged: (_) => setDialogState(() {}),
                    decoration: InputDecoration(
                      labelText: 'Current Email',
                      prefixIcon: const Icon(Icons.email_outlined, size: 20),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF2C2E36) : Colors.grey[200],
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
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
                      fillColor: isDark ? const Color(0xFF2C2E36) : Colors.grey[200],
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
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
                        if (mounted) {
                          Navigator.pop(context, success);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey[800],
                ),
                child: const Text('DELETE PERMANENTLY'),
              ),
            ],
          );
        },
      ),
    );

    if (result == true) {
      if (mounted) {
        // As requested: close the app upon successful deletion
        await SystemNavigator.pop();
      }
    } else if (result == false) {
      _showSnackBar(userProvider.errorMessage ?? 'Deletion failed. Check credentials.',
          isError: true);
    }

    deleteEmailController.dispose();
    deletePasswordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final userProvider = context.watch<UserProvider>();
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Appearance', Icons.palette_outlined),
            Card(
              elevation: 0,
              color: isDark ? const Color(0xFF1C1E26) : Colors.grey[100],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: SwitchListTile(
                title: const Text('Dark Mode'),
                subtitle: Text(isDark ? 'Sleek & Power Saving' : 'Clean & Bright'),
                value: isDark,
                onChanged: (val) => themeProvider.toggleTheme(val),
                secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode,
                    color: Theme.of(context).colorScheme.primary),
              ),
            ),
            const SizedBox(height: 32),
            _buildSectionTitle('Health & Fitness', Icons.fitness_center),
            Card(
              elevation: 0,
              color: isDark ? const Color(0xFF1C1E26) : Colors.grey[100],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Current Weight'),
                    trailing: Text(
                      '${userProvider.weight?.toStringAsFixed(1) ?? "--"} kg',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    onTap: () => setState(() => _isWeightExpanded = !_isWeightExpanded),
                    leading: Icon(Icons.monitor_weight_outlined,
                        color: Theme.of(context).colorScheme.primary),
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    child: _isWeightExpanded
                        ? Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                _buildTextField(
                                  _weightUpdateController,
                                  'New Weight (kg)',
                                  Icons.add_chart_outlined,
                                ),
                                const SizedBox(height: 16),
                                _buildVibrantButton(
                                  label: 'UPDATE WEIGHT',
                                  onPressed: userProvider.isLoading ? null : _handleWeightUpdate,
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
            _buildSectionTitle('Update Profile', Icons.person_outline),
            const Text(
              'Security verification required for all changes.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => setState(() => _isUpdateExpanded = !_isUpdateExpanded),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1C1E26) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _isUpdateExpanded
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.5)
                        : Colors.transparent,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isUpdateExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _isUpdateExpanded ? 'Close Edit Menu' : 'Configure Changes',
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
                        _buildTextField(_emailController, 'Current Email', Icons.email_outlined),
                        const SizedBox(height: 12),
                        _buildTextField(_passwordController, 'Current Password', Icons.lock_outline,
                            isPassword: true),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Divider(height: 1),
                        ),
                        _buildTextField(
                            _newEmailController, 'New Email (Optional)', Icons.alternate_email),
                        const SizedBox(height: 12),
                        _buildTextField(
                            _newPasswordController, 'New Password (Optional)', Icons.vpn_key_outlined,
                            isPassword: true),
                        const SizedBox(height: 24),
                        _buildVibrantButton(
                          label: 'SAVE CHANGES',
                          onPressed: userProvider.isLoading || !_canUpdate ? null : _handleUpdate,
                          isVibrant: _canUpdate,
                          isLoading: userProvider.isLoading,
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
            const SizedBox(height: 48),
            _buildSectionTitle('Danger Zone', Icons.warning_amber_rounded, color: Colors.redAccent),
            Card(
              elevation: 0,
              color: Colors.redAccent.withOpacity(0.05),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Colors.redAccent, width: 0.5)),
              child: ListTile(
                title: const Text('Delete Account', style: TextStyle(color: Colors.redAccent)),
                subtitle: const Text('All data will be permanently removed'),
                trailing: const Icon(Icons.chevron_right, color: Colors.redAccent),
                onTap: _confirmDelete,
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Icon(icon, color: color ?? Theme.of(context).colorScheme.primary, size: 20),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: color ?? Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon,
      {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: context.read<ThemeProvider>().isDarkMode
            ? const Color(0xFF1C1E26)
            : Colors.grey[100],
      ),
    );
  }

  Widget _buildVibrantButton({
    required String label,
    required VoidCallback? onPressed,
    required bool isVibrant,
    required bool isLoading,
  }) {
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
                colors: [
                  Color(0xFF3ECFCF),
                  Color(0xFF6C63FF),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: !isVibrant ? (context.watch<ThemeProvider>().isDarkMode ? Colors.white12 : Colors.grey[300]) : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isVibrant ? Colors.white : Colors.grey[600],
                      letterSpacing: 1.1,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
