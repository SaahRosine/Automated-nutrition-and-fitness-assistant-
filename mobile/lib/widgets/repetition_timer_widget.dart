import 'package:flutter/material.dart';
import '../services/timer_service.dart';

class RepTimerWidget extends StatefulWidget {
  const RepTimerWidget({super.key});

  @override
  State<RepTimerWidget> createState() => _RepTimerWidgetState();
}

class _RepTimerWidgetState extends State<RepTimerWidget> {
  final TimerService _timerService = TimerService();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text("Repetition Timer"),
        StreamBuilder<String>(
          stream: _timerService.repStream,
          builder: (_, snapshot) {
            return Text(
              snapshot.data ?? "1",
              style: const TextStyle(fontSize: 48),
            );
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _timerService.startRepTimer(),
              child: const Text("Start"),
            ),
            ElevatedButton(
              onPressed: () => _timerService.stopRepTimer(),
              child: const Text("Stop"),
            ),
          ],
        )
      ],
    );
  }
}