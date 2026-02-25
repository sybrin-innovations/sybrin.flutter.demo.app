import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/sdk_config.dart';

/// Manages SDK feature flags and persists them across app sessions.
///
/// Backed by [SharedPreferences] so the user's configuration is restored
/// every time the app launches. Subscribe via [ChangeNotifier] as usual:
///
/// ```dart
/// context.watch<AppSettingsProvider>().flags.enableLiveness
/// ```
class AppSettingsProvider extends ChangeNotifier {
  /// The currently active feature flags.
  SdkFeatureFlags _flags = const SdkFeatureFlags();

  /// Read-only view of the current feature flags.
  SdkFeatureFlags get flags => _flags;

  /// Loads persisted preferences. Call once during app startup.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final map = <String, bool>{};

    // Read each stored flag, falling back to the SdkFeatureFlags defaults.
    for (final entry in const SdkFeatureFlags().toMap().entries) {
      map[entry.key] = prefs.getBool(entry.key) ?? entry.value;
    }

    _flags = SdkFeatureFlags.fromMap(map);
    notifyListeners();
  }

  /// Enables or disables the Green Book scanning feature.
  Future<void> setGreenBook(bool value) =>
      _update(_flags.copyWith(enableGreenBook: value));

  /// Enables or disables the Passport scanning feature.
  Future<void> setPassport(bool value) =>
      _update(_flags.copyWith(enablePassport: value));

  /// Enables or disables the ID Card scanning feature.
  Future<void> setIdCard(bool value) =>
      _update(_flags.copyWith(enableIdCard: value));

  /// Enables or disables the Passive Liveness Detection feature.
  Future<void> setLiveness(bool value) =>
      _update(_flags.copyWith(enableLiveness: value));

  /// Enables or disables the Facial Comparison feature.
  Future<void> setFaceCompare(bool value) =>
      _update(_flags.copyWith(enableFaceCompare: value));

  // Persists [newFlags] and notifies listeners.
  Future<void> _update(SdkFeatureFlags newFlags) async {
    _flags = newFlags;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    for (final entry in newFlags.toMap().entries) {
      await prefs.setBool(entry.key, entry.value);
    }
  }
}
