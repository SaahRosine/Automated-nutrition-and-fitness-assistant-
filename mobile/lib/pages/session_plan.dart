import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SessionPlan extends StatelessWidget {
  const SessionPlan({super.key});

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
  final VoidCallback onTap;

  const _PlanButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 28),
        label: Text(label, style: const TextStyle(fontSize: 18)),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 20),
          foregroundColor: Colors.black,
          side: const BorderSide(color: Colors.black),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}