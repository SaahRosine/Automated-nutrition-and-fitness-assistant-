import 'dart:async';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';

class PedometerService {
  StreamSubscription<StepCount>? _stepSubscription;
  int _totalSteps = 0;

  Stream<int> get stepStream => _stepController.stream;
  final StreamController<int> _stepController = StreamController<int>.broadcast();

  int get totalSteps => _totalSteps;

  Future<bool> requestPermission() async {
    final status = await Permission.activityRecognition.request();
    return status.isGranted;
  }

  void startTracking() async {
    if (!await requestPermission()) return;

    _stepSubscription = Pedometer.stepCountStream.listen(
      (StepCount event) {
        _totalSteps = event.steps;
        _stepController.add(_totalSteps);
      },
      onError: (error) {
        // Handle error - could log or show user
        print('Pedometer error: $error');
      },
    );
  }

  void stopTracking() {
    _stepSubscription?.cancel();
    _stepSubscription = null;
  }

  void dispose() {
    stopTracking();
    _stepController.close();
  }
}