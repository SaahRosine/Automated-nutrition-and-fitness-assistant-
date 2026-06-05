import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:mobile/providers/user_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    // Wait for UserProvider to be initialized
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    final userProvider = context.read<UserProvider>();

    // If user is already authenticated, go to home, otherwise go to onboarding
    if (userProvider.isAuthenticated) {
      context.go('/home');
    } else {
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.fitness_center, size: 64),
            const SizedBox(height: 16),
            Text(
              'Stride',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}