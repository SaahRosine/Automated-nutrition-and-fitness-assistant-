import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ThemeProvider extends ChangeNotifier {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      sharedPreferencesName: 'FitnessVault',
    ),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );
  static const _themeKey = 'app_theme_mode';

  ThemeMode _themeMode = ThemeMode.dark;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadTheme();
  }

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  Future<void> _log(String msg) async {
    if (kDebugMode) {
      print('🌓 [ThemeProvider] $msg');
    }
  }

  void toggleTheme(bool isOn) {
    _themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    _saveTheme(_themeMode);
    notifyListeners();
  }

  Future<void> _loadTheme() async {
    await _log('Loading theme...');
    try {
      final savedTheme = await _storage.read(key: _themeKey);
      if (savedTheme == 'light') {
        _themeMode = ThemeMode.light;
        await _log('Light theme loaded.');
      } else {
        _themeMode = ThemeMode.dark;
        await _log('Dark theme loaded (default).');
      }
    } catch (e) {
      await _log('Error loading theme: $e');
    }
    notifyListeners();
  }

  Future<void> _saveTheme(ThemeMode mode) async {
    final value = mode == ThemeMode.light ? 'light' : 'dark';
    await _log('Saving theme: $value');
    await _storage.write(key: _themeKey, value: value);
  }
}
