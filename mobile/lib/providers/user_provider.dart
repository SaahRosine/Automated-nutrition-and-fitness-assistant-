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
  String? _errorMessage;

  // ── Getters ────────────────────────────────────────────────────────────────
  bool get isLoading       => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get token        => _token;
  String? get errorMessage => _errorMessage;

  // ── Init ───────────────────────────────────────────────────────────────────

  /// Call once at app startup (before [runApp] or inside [initState] of the
  /// root widget) to restore a persisted JWT so the user doesn't have to log
  /// in on every launch.
  Future<void> init() async {
    final stored = await _authService.getToken();
    if (stored != null && stored.isNotEmpty) {
      _token = stored;
      _isAuthenticated = true;
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
  }) async {
    _setLoading(true);
    _clearError();

    final result = await _authService.signUp(email: email, password: password);

    if (result.success) {
      _token = result.token;
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

  // ── Private helpers ────────────────────────────────────────────────────────

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
