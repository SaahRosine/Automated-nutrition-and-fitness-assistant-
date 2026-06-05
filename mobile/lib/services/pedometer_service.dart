import 'dart:async';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';

class PedometerService {
  StreamSubscription<StepCount>? _stepSubscription;
  int _totalSteps = 0;
  int _initialSteps = 0;  // Track starting step count
  int _sessionSteps = 0;  // Relative steps for current session

  Stream<int> get stepStream => _stepController.stream;
  final StreamController<int> _stepController = StreamController<int>.broadcast();

  int get totalSteps => _sessionSteps;

  Future<bool> requestPermission() async {
    final status = await Permission.activityRecognition.request();
    return status.isGranted;
  }

  void startTracking() async {
    if (!await requestPermission()) return;

    _stepSubscription = Pedometer.stepCountStream.listen(
      (StepCount event) {
        _totalSteps = event.steps;
        
        // Set initial step count on first reading
        if (_initialSteps == 0) {
          _initialSteps = _totalSteps;
        }
        
        // Calculate relative steps for this session
        _sessionSteps = (_totalSteps - _initialSteps).abs();
        _stepController.add(_sessionSteps);
      },
      onError: (error) {
        print('Pedometer error: $error');
      },
    );
  }

  void stopTracking() {
    _stepSubscription?.cancel();
    _stepSubscription = null;
    // Reset for next session
    _initialSteps = 0;
    _sessionSteps = 0;
  }

  void dispose() {
    stopTracking();
    _stepController.close();
  }
}