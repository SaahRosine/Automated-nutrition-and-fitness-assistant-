import 'package:flutter/foundation.dart';
import 'package:mobile/services/auth_service.dart';

/// Application-wide authentication state.
///
/// Consumed by the UI via `context.watch<UserProvider>()` or
/// `context.read<UserProvider>()`.  Never talk to [AuthService] directly
/// from a widget — always go through this provider.
class UserProvider extends ChangeNotifier {
  final AuthService _authService;

  UserProvider({AuthService? authService})
      : _authService = authService ?? AuthService();

  // ── State ──────────────────────────────────────────────────────────────────
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _token;
  double? _weight;
  String? _email;
  String? _errorMessage;

  // ── Getters ────────────────────────────────────────────────────────────────
  bool get isLoading       => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get token        => _token;
  double? get weight       => _weight;
  String? get email        => _email;
  String? get errorMessage => _errorMessage;

  // ── Init ───────────────────────────────────────────────────────────────────

  /// Call once at app startup (before [runApp] or inside [initState] of the
  /// root widget) to restore a persisted JWT so the user doesn't have to log
  /// in on every launch.
  Future<void> init() async {
    final storedToken = await _authService.getToken();
    if (storedToken != null && storedToken.isNotEmpty) {
      _token = storedToken;
      _isAuthenticated = true;
      _weight = await _authService.getWeight();
      _email = await _authService.getEmail();
    }
    notifyListeners();
  }

  // ── Auth actions ───────────────────────────────────────────────────────────

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    final result = await _authService.login(email: email, password: password);

    if (result.success) {
      _token = result.token;
      _weight = result.weight;
      _email = result.email;
      _isAuthenticated = true;
      _setLoading(false);
      return true;
    }

    _errorMessage = result.error;
    _setLoading(false);
    return false;
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required double weight,
  }) async {
    _setLoading(true);
    _clearError();

    final result = await _authService.signUp(
      email: email,
      password: password,
      weight: weight,
    );

    if (result.success) {
      _token = result.token;
      _weight = result.weight;
      _email = result.email;
      _isAuthenticated = true;
      _setLoading(false);
      return true;
    }

    _errorMessage = result.error;
    _setLoading(false);
    return false;
  }

  /// Rotates (refreshes) the current JWT. Typically called on app foreground.
  Future<void> rotateToken() async {
    final result = await _authService.rotateToken();
    if (result.success) {
      _token = result.token;
      notifyListeners();
    }
    // A failed rotation is silent — the user's session just expires naturally.
  }

  /// Clears all local auth state and secure storage.
  Future<void> logout() async {
    await _authService.deleteToken();
    _token = null;
    _weight = null;
    _email = null;
    _isAuthenticated = false;
    _clearError();
    notifyListeners();
  }

  Future<bool> updateProfile({
    required String email,
    required String password,
    String? newEmail,
    String? newPassword,
  }) async {
    _setLoading(true);
    _clearError();

    final result = await _authService.updateProfile(
      email: email,
      password: password,
      newEmail: newEmail,
      newPassword: newPassword,
    );

    if (result.success) {
      if (result.token != null && result.token!.isNotEmpty) {
        _token = result.token;
      }
      _setLoading(false);
      return true;
    }

    _errorMessage = result.error;
    _setLoading(false);
    return false;
  }

  Future<bool> deleteAccount({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    final result = await _authService.deleteAccount(
      email: email,
      password: password,
    );

    if (result.success) {
      _token = null;
      _isAuthenticated = false;
      _setLoading(false);
      return true;
    }

    _errorMessage = result.error;
    _setLoading(false);
    return false;
  }

  Future<bool> updateWeight(double newWeight) async {
    if (_email == null) {
      _errorMessage = 'Email not found for update';
      return false;
    }

    _setLoading(true);
    _clearError();

    final result = await _authService.updateWeight(
      email: _email!,
      weight: newWeight,
    );

    if (result.success) {
      _weight = result.weight ?? newWeight;
      _setLoading(false);
      return true;
    }

    _errorMessage = result.error;
    _setLoading(false);
    return false;
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
