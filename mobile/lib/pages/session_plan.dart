import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:mobile/providers/session_provider.dart';
import 'package:mobile/providers/user_provider.dart';

class SessionPlan extends StatefulWidget {
  const SessionPlan({super.key});

  @override
  State<SessionPlan> createState() => _SessionPlanState();
}

class _SessionPlanState extends State<SessionPlan> {
  bool _isRequesting = false;

  Future<void> _startSession() async {
    final userProvider = context.read<UserProvider>();
    final sessionProvider = context.read<SessionProvider>();

    // Check if user is authenticated
    if (!userProvider.isAuthenticated) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in first')),
      );
      return;
    }

    setState(() => _isRequesting = true);

    try {
      // Request permissions
      final permissionsGranted = await sessionProvider.requestPermissions();

      if (!mounted) return;

      if (permissionsGranted) {
        // Start the session
        sessionProvider.startSession();
        // Navigate to active session screen
        context.go('/session-active');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(sessionProvider.errorMessage ?? 'Permissions denied')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error starting session: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isRequesting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plan Session'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _PlanButton(
              label: 'Start Running Session',
              icon: Icons.directions_run,
              isLoading: _isRequesting,
              onTap: _isRequesting ? null : _startSession,
            ),
            const SizedBox(height: 20),
            _PlanButton(
              label: 'Use Camera',
              icon: Icons.camera_alt,
              onTap: () {
                // Camera functionality will come later
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Camera feature coming soon')),
                );
              },
            ),
            const SizedBox(height: 20),
            _PlanButton(
              label: 'Set Up Manually',
              icon: Icons.edit,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Manual setup coming soon')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool isLoading;

  const _PlanButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: isLoading ? null : onTap,
        icon: isLoading ? const SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(strokeWidth: 2),
        ) : Icon(icon, size: 28),
        label: Text(label, style: const TextStyle(fontSize: 18)),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 20),
          foregroundColor: Colors.black,
          side: const BorderSide(color: Colors.black),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          disabledForegroundColor: Colors.grey,
        ),
      ),
    );
  }
}