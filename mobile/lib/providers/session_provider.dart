import 'package:flutter/foundation.dart';
import 'package:mobile/services/session_controller.dart';

/// Manages the active workout session state using [SessionController].
///
/// Wraps [SessionController] in a ChangeNotifier so UI screens can listen
/// to session progress via Provider pattern.
class SessionProvider extends ChangeNotifier {
  final SessionController _sessionController = SessionController();

  // ── State ──────────────────────────────────────────────────────────────────
  bool _isSessionActive = false;
  bool _isSessionPaused = false;
  int _elapsedSeconds = 0;
  int _steps = 0;
  double _distance = 0.0; // in meters
  double _speed = 0.0;
  String? _errorMessage;

  // ── Getters ────────────────────────────────────────────────────────────────
  bool get isSessionActive => _isSessionActive;
  bool get isSessionPaused => _isSessionPaused;
  int get elapsedSeconds => _elapsedSeconds;
  int get steps => _steps;
  double get distance => _distance; // meters
  double get speed => _speed;
  String? get errorMessage => _errorMessage;

  SessionController get controller => _sessionController;

  /// Formatted elapsed time as HH:MM:SS.
  String get formattedTime {
    final hours = _elapsedSeconds ~/ 3600;
    final minutes = (_elapsedSeconds % 3600) ~/ 60;
    final seconds = _elapsedSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // ── Initialization ─────────────────────────────────────────────────────────

  /// Request necessary permissions for location and activity tracking.
  Future<bool> requestPermissions() async {
    final granted = await _sessionController.requestPermissions();
    if (!granted) {
      _errorMessage = 'Location and activity permissions are required';
      notifyListeners();
    }
    return granted;
  }

  // ── Session actions ────────────────────────────────────────────────────────

  /// Start a new workout session.
  void startSession() {
    _sessionController.startSession();
    _isSessionActive = true;
    _isSessionPaused = false;
    _elapsedSeconds = 0;
    _steps = 0;
    _distance = 0.0;
    _errorMessage = null;

    // Listen to controller streams
    _subscribeToStreams();
  }

  /// Pause the current session.
  void pauseSession() {
    if (_isSessionActive) {
      _sessionController.pauseSession();
      _isSessionPaused = true;
      notifyListeners();
    }
  }

  /// Resume a paused session.
  void resumeSession() {
    if (_isSessionActive && _isSessionPaused) {
      _sessionController.resumeSession();
      _isSessionPaused = false;
      notifyListeners();
    }
  }

  /// Stop the current session and return session data.
  SessionData? stopSession({
    required double weightKg,
    required String workoutType,
    required String intensity,
  }) {
    if (!_isSessionActive) return null;

    _sessionController.stopSession();
    _isSessionActive = false;
    _isSessionPaused = false;

    final data = _sessionController.getSessionData(
      weightKg: weightKg,
      workoutType: workoutType,
      intensity: intensity,
    );

    // Reset state
    _elapsedSeconds = 0;
    _steps = 0;
    _distance = 0.0;
    _speed = 0.0;

    notifyListeners();
    return data;
  }

  /// Subscribe to controller streams and update state.
  void _subscribeToStreams() {
    // Listen to time updates
    _sessionController.elapsedTimeStream.listen((seconds) {
      _elapsedSeconds = seconds;
      notifyListeners();
    });

    // Listen to step updates
    _sessionController.stepStream.listen((steps) {
      _steps = steps;
      notifyListeners();
    });

    // Listen to distance updates
    _sessionController.distanceStream.listen((distance) {
      _distance = distance;
      notifyListeners();
    });

    // Listen to speed updates
    _sessionController.speedStream.listen((speed) {
      _speed = speed;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    if (_isSessionActive) {
      _sessionController.stopSession();
    }
    super.dispose();
  }
}
