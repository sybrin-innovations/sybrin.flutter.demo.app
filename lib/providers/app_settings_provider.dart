import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/sdk_config.dart';

/// Manages SDK feature flags and persists them across app sessions.
class AppSettingsProvider extends ChangeNotifier {
  SdkFeatureFlags _flags = const SdkFeatureFlags();
  SdkFeatureFlags get flags => _flags;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final map = <String, bool>{};
    for (final entry in const SdkFeatureFlags().toMap().entries) {
      map[entry.key] = prefs.getBool(entry.key) ?? entry.value;
    }
    _flags = SdkFeatureFlags.fromMap(map);
    notifyListeners();
  }

  Future<void> setLiveness(bool value) =>
      _update(_flags.copyWith(enableLiveness: value));

  Future<void> setFaceCompare(bool value) =>
      _update(_flags.copyWith(enableFaceCompare: value));

  Future<void> _update(SdkFeatureFlags newFlags) async {
    _flags = newFlags;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    for (final entry in newFlags.toMap().entries) {
      await prefs.setBool(entry.key, entry.value);
    }
  }
}
