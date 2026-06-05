import 'dart:async';
import 'package:geolocator/geolocator.dart';

class LocationService {
  final _positionController = StreamController<Position>.broadcast();
  Stream<Position> get positionStream => _positionController.stream;

  final _distanceController = StreamController<double>.broadcast();
  Stream<double> get distanceStream => _distanceController.stream;

  final _speedController = StreamController<double>.broadcast();
  Stream<double> get speedStream => _speedController.stream;

  double _totalDistance = 0;
  double _currentSpeed = 0;
  Position? _lastPosition;
  DateTime? _lastTimestamp;

  double get totalDistance => _totalDistance;
  double get currentSpeed => _currentSpeed;

  StreamSubscription<Position>? _subscription;

  Future<bool> requestPermission() async {
    var permission = await Geolocator.requestPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  void startTracking() async {
    _subscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, // meters (battery optimization)
      ),
    ).listen((Position position) {
      // Calculate distance since last position
      if (_lastPosition != null) {
        final distanceDelta = Geolocator.distanceBetween(
          _lastPosition!.latitude,
          _lastPosition!.longitude,
          position.latitude,
          position.longitude,
        );
        _totalDistance += distanceDelta;
        _distanceController.add(_totalDistance);
        
        // Calculate speed (m/s)
        if (_lastTimestamp != null) {
          final timeDelta = position.timestamp.difference(_lastTimestamp!).inSeconds;
          if (timeDelta > 0) {
            _currentSpeed = distanceDelta / timeDelta;
            _speedController.add(_currentSpeed);
          }
        }
      }

      _lastPosition = position;
      _lastTimestamp = position.timestamp;
      _positionController.add(position);
    });
  }

  void stopTracking() {
    _subscription?.cancel();
    _currentSpeed = 0;
  }

  void dispose() {
    stopTracking();
    _positionController.close();
    _distanceController.close();
    _speedController.close();
  }
}