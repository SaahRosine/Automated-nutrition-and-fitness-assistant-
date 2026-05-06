import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:mobile/core/constants/app_styles.dart';
import 'package:mobile/providers/user_provider.dart';
import 'package:mobile/widgets/glass_card.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _weightController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<UserProvider>();
    final success = await provider.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      weight: double.tryParse(_weightController.text.trim()) ?? 0,
    );

    if (!mounted) return;
    if (success) {
      context.go('/home');
    } else {
      _showSnack(provider.errorMessage ?? 'Unable to create account.');
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.darkSurfaceAlt,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<UserProvider>().isLoading;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Create account', style: AppTextStyles.heading1.copyWith(fontSize: 32)),
                      const SizedBox(height: 8),
                      Text('Start tracking runs and leveling up your fitness.', style: AppTextStyles.body.copyWith(color: AppColors.white70)),
                    ],
                  ),
                  const CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.secondary,
                    child: Icon(Icons.emoji_events_rounded, color: AppColors.white, size: 28),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              GlassCard(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Email', style: AppTextStyles.label),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: AppColors.white),
                        decoration: _inputDecoration(hintText: 'hello@stride.app', icon: Icons.mail_outline_rounded),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Email is required';
                          if (!value.contains('@')) return 'Enter a valid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),
                      Text('Weight', style: AppTextStyles.label),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _weightController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: AppColors.white),
                        decoration: _inputDecoration(hintText: 'kg', icon: Icons.monitor_weight_rounded),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Weight is required';
                          if (double.tryParse(value) == null) return 'Enter a number';
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),
                      Text('Password', style: AppTextStyles.label),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: const TextStyle(color: AppColors.white),
                        decoration: _inputDecoration(
                          hintText: 'Minimum 8 characters',
                          icon: Icons.lock_outline_rounded,
                          suffix: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: AppColors.white54),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Password is required';
                          if (value.length < 8) return 'Password too short';
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),
                      Text('Confirm', style: AppTextStyles.label),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _confirmController,
                        obscureText: _obscureConfirm,
                        style: const TextStyle(color: AppColors.white),
                        decoration: _inputDecoration(
                          hintText: 'Re-enter password',
                          icon: Icons.lock_outline_rounded,
                          suffix: IconButton(
                            icon: Icon(_obscureConfirm ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: AppColors.white54),
                            onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                          ),
                        ),
                        validator: (value) {
                          if (value != _passwordController.text) return 'Passwords do not match';
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(56),
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: isLoading
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.white))
                            : const Text('Create account', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Already have an account?', style: AppTextStyles.body.copyWith(color: AppColors.white54)),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => context.go('/login'),
                    child: const Text('Sign in', style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w700)),
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

  InputDecoration _inputDecoration({required String hintText, required IconData icon, Widget? suffix}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: AppColors.white38),
      prefixIcon: Icon(icon, color: AppColors.white38),
      suffixIcon: suffix,
      filled: true,
      fillColor: AppColors.white10,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
    );
  }
}
