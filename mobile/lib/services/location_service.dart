import 'dart:async';
import 'dart:math';
import 'package:geolocator/geolocator.dart';

class LocationService {
  StreamSubscription<Position>? _positionSubscription;
  final List<Position> _positions = [];
  double _totalDistance = 0.0;
  double _currentSpeed = 0.0;

  Stream<double> get distanceStream => _distanceController.stream;
  Stream<double> get speedStream => _speedController.stream;

  final StreamController<double> _distanceController = StreamController<double>.broadcast();
  final StreamController<double> _speedController = StreamController<double>.broadcast();

  double get totalDistance => _totalDistance;
  double get currentSpeed => _currentSpeed;

  Future<bool> requestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.always || permission == LocationPermission.whileInUse;
  }

  void startTracking() async {
    if (!await requestPermission()) return;

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5, // Update every 5 meters
    );

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      _positions.add(position);
      _updateDistance();
      _updateSpeed(position);
    });
  }

  void _updateDistance() {
    if (_positions.length < 2) return;

    final previous = _positions[_positions.length - 2];
    final current = _positions.last;

    final distance = _calculateDistance(previous, current);
    _totalDistance += distance;
    _distanceController.add(_totalDistance);
  }

  void _updateSpeed(Position position) {
    _currentSpeed = position.speed * 3.6; // Convert m/s to km/h
    _speedController.add(_currentSpeed);
  }

  double _calculateDistance(Position p1, Position p2) {
    const double earthRadius = 6371000; // meters

    final lat1Rad = p1.latitude * pi / 180;
    final lat2Rad = p2.latitude * pi / 180;
    final deltaLatRad = (p2.latitude - p1.latitude) * pi / 180;
    final deltaLngRad = (p2.longitude - p1.longitude) * pi / 180;

    final a = sin(deltaLatRad / 2) * sin(deltaLatRad / 2) +
        cos(lat1Rad) * cos(lat2Rad) * sin(deltaLngRad / 2) * sin(deltaLngRad / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  void stopTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  void dispose() {
    stopTracking();
    _distanceController.close();
    _speedController.close();
  }
}