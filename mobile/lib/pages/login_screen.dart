import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:mobile/core/constants/app_styles.dart';
import 'package:mobile/providers/user_provider.dart';
import 'package:mobile/widgets/glass_card.dart';

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
        child: SingleChildScrollView(
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
                      Text('Welcome back', style: AppTextStyles.heading1.copyWith(fontSize: 32)),
                      const SizedBox(height: 8),
                      Text('Log in to track your next session.', style: AppTextStyles.body.copyWith(color: AppColors.white70)),
                    ],
                  ),
                  const CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.fitness_center_rounded, color: AppColors.white, size: 28),
                  ),
                ],
              ),
              const SizedBox(height: 30),
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
                      Text('Password', style: AppTextStyles.label),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscureText,
                        style: const TextStyle(color: AppColors.white),
                        decoration: _inputDecoration(
                          hintText: '••••••••',
                          icon: Icons.lock_outline_rounded,
                          suffix: IconButton(
                            icon: Icon(_obscureText ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: AppColors.white54),
                            onPressed: () => setState(() => _obscureText = !_obscureText),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Password is required';
                          if (value.length < 8) return 'Use at least 8 characters';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => _showSnack('Password reset flow is coming soon.'),
                          child: const Text('Forgot password?', style: TextStyle(color: AppColors.white70)),
                        ),
                      ),
                      const SizedBox(height: 6),
                      ElevatedButton(
                        onPressed: isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(56),
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: isLoading
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.white))
                            : const Text('Continue', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Center(
                child: Text('Or connect with', style: AppTextStyles.body.copyWith(color: AppColors.white54)),
              ),
              
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('New to Stride?', style: AppTextStyles.body.copyWith(color: AppColors.white54)),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => context.go('/register'),
                    child: const Text('Create account', style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w700)),
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      hintText: hintText,
      hintStyle: const TextStyle(color: AppColors.white38),
      prefixIcon: Icon(icon, color: AppColors.white38),
      suffixIcon: suffix,
      filled: true,
      fillColor: AppColors.white10,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
    );
  }
}
