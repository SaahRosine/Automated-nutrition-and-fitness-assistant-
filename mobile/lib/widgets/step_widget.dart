import 'package:flutter/material.dart';
import '../services/session_controller.dart';

class StepWidget extends StatelessWidget {
  final SessionController session;

  const StepWidget({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: session.stepStream,
      builder: (context, snapshot) {
        final steps = snapshot.data ?? 0;

        return Column(
          children: [
            const Text("Steps", style: TextStyle(fontSize: 18)),
            Text("$steps",
                style: const TextStyle(
                    fontSize: 32, fontWeight: FontWeight.bold)),
          ],
        );
      },
    );
  }
}