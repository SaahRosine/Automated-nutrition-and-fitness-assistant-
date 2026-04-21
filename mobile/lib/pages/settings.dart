import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/providers/user_provider.dart';
import 'package:mobile/providers/theme_provider.dart';

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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _newEmailController.dispose();
    _newPasswordController.dispose();
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

  Future<void> _confirmDelete() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar('Current email and password are required to delete account', isError: true);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account?'),
        content: const Text(
            'This action is permanent and cannot be undone. All your data will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await context.read<UserProvider>().deleteAccount(
            email: email,
            password: password,
          );

      if (success) {
        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } else {
        if (mounted) {
          _showSnackBar(context.read<UserProvider>().errorMessage ?? 'Deletion failed',
              isError: true);
        }
      }
    }
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
            _buildSectionTitle('Update Profile', Icons.person_outline),
            const Text(
              'Security verification required for all changes.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            _buildTextField(_emailController, 'Current Email', Icons.email_outlined),
            const SizedBox(height: 12),
            _buildTextField(_passwordController, 'Current Password', Icons.lock_outline,
                isPassword: true),
            const Divider(height: 40),
            _buildTextField(_newEmailController, 'New Email (Optional)', Icons.alternate_email),
            const SizedBox(height: 12),
            _buildTextField(_newPasswordController, 'New Password (Optional)', Icons.vpn_key_outlined,
                isPassword: true),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: userProvider.isLoading ? null : _handleUpdate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: userProvider.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('UPDATE PROFILE',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
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
        fillColor: context.watch<ThemeProvider>().isDarkMode
            ? const Color(0xFF1C1E26)
            : Colors.grey[100],
      ),
    );
  }
}
