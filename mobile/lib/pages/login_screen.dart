import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:mobile/core/constants/app_styles.dart';
import 'package:mobile/providers/user_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscureText = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<UserProvider>();
    final success = await provider.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    if (!mounted) return;
    if (success) {
      context.go('/home');
    } else {
      _showSnack(provider.errorMessage ?? 'Unable to sign in.');
    }
  }

  void _showSnack(String message) {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: theme.colorScheme.surfaceVariant,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<UserProvider>().isLoading;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Welcome back', style: AppTextStyles.heading1(context).copyWith(fontSize: 32)),
                      const SizedBox(height: 8),
                      Text(
                        'Log in to track your next session.',
                        style: AppTextStyles.body(context).copyWith(
                          color: theme.colorScheme.onBackground.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: theme.colorScheme.primary,
                    child: Icon(Icons.fitness_center_rounded, color: Colors.white, size: 28),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Email', style: AppTextStyles.label(context)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(color: theme.colorScheme.onBackground),
                          decoration: _inputDecoration(context, hintText: 'hello@stride.app', icon: Icons.mail_outline_rounded),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Email is required';
                            if (!value.contains('@')) return 'Enter a valid email';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        Text('Password', style: AppTextStyles.label(context)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscureText,
                          style: TextStyle(color: theme.colorScheme.onBackground),
                          decoration: _inputDecoration(
                            context,
                            hintText: '••••••••',
                            icon: Icons.lock_outline_rounded,
                            suffix: IconButton(
                              icon: Icon(
                                _obscureText ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                color: theme.colorScheme.onBackground.withOpacity(0.5),
                              ),
                              onPressed: () => setState(() => _obscureText = !_obscureText),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Password is required';
                            if (value.length < 8) return 'Use at least 8 characters';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => _showSnack('Password reset flow is coming soon.'),
                            child: Text(
                              'Forgot password?',
                              style: TextStyle(
                                color: theme.colorScheme.onBackground.withOpacity(0.7),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(56),
                          ),
                          child: isLoading
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                              : const Text('Continue', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  'Or connect with',
                  style: AppTextStyles.body(context).copyWith(
                    color: theme.colorScheme.onBackground.withOpacity(0.5),
                  ),
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'New to Stride?',
                    style: AppTextStyles.body(context).copyWith(
                      color: theme.colorScheme.onBackground.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => context.go('/register'),
                    child: Text(
                      'Create account',
                      style: TextStyle(
                        color: theme.colorScheme.secondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(BuildContext context, {required String hintText, required IconData icon, Widget? suffix}) {
    final theme = Theme.of(context);
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintText: hintText,
      hintStyle: TextStyle(color: theme.colorScheme.onBackground.withOpacity(0.4)),
      prefixIcon: Icon(icon, color: theme.colorScheme.onBackground.withOpacity(0.4)),
      suffixIcon: suffix,
      filled: true,
      fillColor: theme.colorScheme.surfaceVariant,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
    );
  }
}
