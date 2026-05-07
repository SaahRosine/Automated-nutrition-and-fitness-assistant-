import 'dart:async';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:mobile/services/location_service.dart';
import 'package:mobile/services/pedometer_service.dart';

// The callback function should always be a top-level or static function.
@pragma('vm:entry-point')
void startTrackingCallback() {
  FlutterForegroundTask.setTaskHandler(TrackingTaskHandler());
}

class TrackingTaskHandler extends TaskHandler {
  final LocationService _locationService = LocationService();
  final PedometerService _pedometerService = PedometerService();
  Timer? _updateTimer;
  int _steps = 0;
  double _distance = 0.0;
  int _duration = 0;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    print('Tracking task started');

    // Request permissions
    final locationGranted = await _locationService.requestPermission();
    final activityGranted = await _pedometerService.requestPermission();

    if (locationGranted && activityGranted) {
      // Start tracking
      _locationService.startTracking();
      _pedometerService.startTracking();

      // Start periodic updates
      _updateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _duration++;
        _steps = _pedometerService.totalSteps;
        _distance = _locationService.totalDistance;

        // Update notification with beautiful formatting
        FlutterForegroundTask.updateService(
          notificationTitle: '🏃‍♂️ Active Workout Session',
          notificationText: '👣 $_steps steps • 📍 ${_distance.toStringAsFixed(1)}km • ⏱️ ${_formatDuration(_duration)}',
        );
      });
    }
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    // This is called based on eventAction interval, but we handle updates in timer
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    print('Tracking task destroyed');

    // Stop tracking
    _locationService.stopTracking();
    _pedometerService.stopTracking();
    _updateTimer?.cancel();

    // Dispose services
    _locationService.dispose();
    _pedometerService.dispose();
  }

  @override
  void onReceiveData(Object data) {
    // Handle data sent from main isolate if needed
  }

  @override
  void onNotificationButtonPressed(String id) {
    // Handle notification button presses if needed
  }

  @override
  void onNotificationPressed() {
    // Handle notification tap if needed
    FlutterForegroundTask.launchApp();
  }

  @override
  void onNotificationDismissed() {
    // Handle notification dismissal if needed
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${secs}s';
    } else {
      return '${minutes}m ${secs}s';
    }
  }
}