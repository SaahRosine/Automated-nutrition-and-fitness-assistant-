import 'dart:async';
import 'package:vibration/vibration.dart';

class TimerService {
  Timer? _repTimer;
  Timer? _countdownTimer;

  final _repController = StreamController<String>.broadcast();
  Stream<String> get repStream => _repController.stream;

  final _countdownController = StreamController<int>.broadcast();
  Stream<int> get countdownStream => _countdownController.stream;

  int _remaining = 0;
  bool _toggle = true;

  void startRepTimer({int intervalMs = 1000}) {
    _repTimer?.cancel();

    _repTimer = Timer.periodic(Duration(milliseconds: intervalMs), (_) async {
      _toggle = !_toggle;
      _repController.add(_toggle ? "1" : "2");

      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(duration: 50);
      }
    });
  }

  void stopRepTimer() {
    _repTimer?.cancel();
  }

  void startCountdown(int seconds) {
    _remaining = seconds;
    _countdownController.add(_remaining);

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _remaining--;
      _countdownController.add(_remaining);

      if (_remaining <= 0) {
        timer.cancel();
      }
    });
  }

  void pauseCountdown() {
    _countdownTimer?.cancel();
  }

  void dispose() {
    _repTimer?.cancel();
    _countdownTimer?.cancel();
    _repController.close();
    _countdownController.close();
  }
}