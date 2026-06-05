import 'package:flutter/material.dart';
import '../services/timer_service.dart';

class StaticTimerWidget extends StatefulWidget {
  const StaticTimerWidget({super.key});

  @override
  State<StaticTimerWidget> createState() => _StaticTimerWidgetState();
}

class _StaticTimerWidgetState extends State<StaticTimerWidget> {
  final TimerService _timerService = TimerService();
  final TextEditingController _controller = TextEditingController(text: "30");

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text("Static Timer"),
        TextField(
          controller: _controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "Seconds"),
        ),
        StreamBuilder<int>(
          stream: _timerService.countdownStream,
          builder: (_, snapshot) {
            return Text(
              "${snapshot.data ?? 0}s",
              style: const TextStyle(fontSize: 32),
            );
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                final seconds = int.parse(_controller.text);
                _timerService.startCountdown(seconds);
              },
              child: const Text("Start"),
            ),
            ElevatedButton(
              onPressed: _timerService.pauseCountdown,
              child: const Text("Pause"),
            ),
          ],
        )
      ],
    );
  }
}