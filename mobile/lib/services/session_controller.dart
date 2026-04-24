import 'dart:async';
import 'package:mobile/services/location_service.dart';
import 'package:mobile/services/pedometer_service.dart';

class SessionData {
  final int steps;
  final double distance; // in meters
  final int duration; // in seconds
  final int calories;

  SessionData({
    required this.steps,
    required this.distance,
    required this.duration,
    required this.calories,
  });
}

class SessionController {
  final LocationService _locationService = LocationService();
  final PedometerService _pedometerService = PedometerService();

  Timer? _timer;
  int _elapsedSeconds = 0;

  Stream<int> get elapsedTimeStream => _timeController.stream;
  Stream<int> get stepStream => _pedometerService.stepStream;
  Stream<double> get distanceStream => _locationService.distanceStream;
  Stream<double> get speedStream => _locationService.speedStream;

  final StreamController<int> _timeController = StreamController<int>.broadcast();

  int get elapsedSeconds => _elapsedSeconds;
  int get steps => _pedometerService.totalSteps;
  double get distance => _locationService.totalDistance;
  double get speed => _locationService.currentSpeed;

  Future<bool> requestPermissions() async {
    final locationGranted = await _locationService.requestPermission();
    final activityGranted = await _pedometerService.requestPermission();
    return locationGranted && activityGranted;
  }

  void startSession() {
    _locationService.startTracking();
    _pedometerService.startTracking();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _elapsedSeconds++;
      _timeController.add(_elapsedSeconds);
    });
  }

  void stopSession() {
    _locationService.stopTracking();
    _pedometerService.stopTracking();
    _timer?.cancel();
    _timer = null;
  }

  int calculateCalories({
    required double weightKg,
    required String workoutType,
    required String intensity,
  }) {
    if (_elapsedSeconds == 0) return 0;

    // Use distance-based calculation for running
    if (workoutType == 'running' && distance > 0) {
      // Approximate calories per km for running
      const caloriesPerKm = 60.0; // average for moderate running
      return (distance / 1000 * caloriesPerKm).round();
    }

    // Fallback to MET-based calculation
    const metValues = {
      'running': {'low': 6.0, 'moderate': 8.0, 'high': 10.0},
    };

    final met = metValues[workoutType]?[intensity] ?? 8.0;
    final hours = _elapsedSeconds / 3600.0;
    return (met * weightKg * hours).round();
  }

  SessionData getSessionData({
    required double weightKg,
    required String workoutType,
    required String intensity,
  }) {
    return SessionData(
      steps: steps,
      distance: distance,
      duration: _elapsedSeconds,
      calories: calculateCalories(
        weightKg: weightKg,
        workoutType: workoutType,
        intensity: intensity,
      ),
    );
  }

  void dispose() {
    stopSession();
    _locationService.dispose();
    _pedometerService.dispose();
    _timeController.close();
  }
}