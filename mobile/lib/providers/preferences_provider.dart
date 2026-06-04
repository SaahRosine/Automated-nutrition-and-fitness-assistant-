import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

enum DistanceUnit { km, miles }

enum WeightUnit { kg, lbs }

/// Persists user preferences (units, notifications) across sessions.
class PreferencesProvider extends ChangeNotifier {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const _distanceKey = 'pref_distance_unit';
  static const _weightKey = 'pref_weight_unit';
  static const _notificationsKey = 'pref_notifications';

  DistanceUnit _distanceUnit = DistanceUnit.km;
  WeightUnit _weightUnit = WeightUnit.kg;
  bool _notificationsEnabled = true;

  DistanceUnit get distanceUnit => _distanceUnit;
  WeightUnit get weightUnit => _weightUnit;
  bool get notificationsEnabled => _notificationsEnabled;

  bool get isMetric => _distanceUnit == DistanceUnit.km;

  /// Load persisted preferences. Call once at app startup.
  Future<void> init() async {
    final distStr = await _storage.read(key: _distanceKey);
    final weightStr = await _storage.read(key: _weightKey);
    final notifStr = await _storage.read(key: _notificationsKey);

    _distanceUnit = distStr == 'miles' ? DistanceUnit.miles : DistanceUnit.km;
    _weightUnit = weightStr == 'lbs' ? WeightUnit.lbs : WeightUnit.kg;
    _notificationsEnabled = notifStr != 'false';

    notifyListeners();
  }

  Future<void> setDistanceUnit(DistanceUnit unit) async {
    _distanceUnit = unit;
    await _storage.write(
      key: _distanceKey,
      value: unit == DistanceUnit.miles ? 'miles' : 'km',
    );
    notifyListeners();
  }

  Future<void> setWeightUnit(WeightUnit unit) async {
    _weightUnit = unit;
    await _storage.write(
      key: _weightKey,
      value: unit == WeightUnit.lbs ? 'lbs' : 'kg',
    );
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    await _storage.write(
      key: _notificationsKey,
      value: enabled ? 'true' : 'false',
    );
    notifyListeners();
  }

  // ── Conversion helpers ─────────────────────────────────────────────────────

  /// Convert metres to the preferred distance unit string (e.g. "5.2 km").
  String formatDistance(int meters) {
    if (_distanceUnit == DistanceUnit.miles) {
      final miles = meters / 1609.344;
      return '${miles.toStringAsFixed(2)} mi';
    }
    final km = meters / 1000.0;
    return '${km.toStringAsFixed(2)} km';
  }

  /// Convert kg to the preferred weight unit string (e.g. "70.0 kg").
  String formatWeight(double kg) {
    if (_weightUnit == WeightUnit.lbs) {
      final lbs = kg * 2.20462;
      return '${lbs.toStringAsFixed(1)} lbs';
    }
    return '${kg.toStringAsFixed(1)} kg';
  }

  String get distanceUnitLabel =>
      _distanceUnit == DistanceUnit.miles ? 'mi' : 'km';

  String get weightUnitLabel =>
      _weightUnit == WeightUnit.lbs ? 'lbs' : 'kg';
}
