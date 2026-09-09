import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalPreferencesHelper {
  final SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage;
  String? _cachedAuthToken;

  LocalPreferencesHelper(this._prefs, {FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage() {
    _secureStorage.read(key: _kAuthToken).then((token) {
      _cachedAuthToken = token;
    });
  }

  static const String _kHasSeenOnboarding = 'has_seen_onboarding';
  static const String _kAuthToken = 'auth_token';
  static const String _kIsDarkMode = 'is_dark_mode';

  bool get hasSeenOnboarding => _prefs.getBool(_kHasSeenOnboarding) ?? false;
  Future<bool> setHasSeenOnboarding(bool value) async =>
      await _prefs.setBool(_kHasSeenOnboarding, value);

  String? get authToken => _cachedAuthToken;

  Future<void> setAuthToken(String token) async {
    _cachedAuthToken = token;
    await _secureStorage.write(key: _kAuthToken, value: token);
  }

  Future<void> clearAuthToken() async {
    _cachedAuthToken = null;
    await _secureStorage.delete(key: _kAuthToken);
  }

  bool get isDarkMode => _prefs.getBool(_kIsDarkMode) ?? false;
  Future<bool> setDarkMode(bool value) async =>
      await _prefs.setBool(_kIsDarkMode, value);
}
