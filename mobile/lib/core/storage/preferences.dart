import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper over SharedPreferences for type-safe access.
///
/// Stores: last sync timestamps, selected filters, UI preferences.
class Preferences {
  const Preferences(this._prefs);

  final SharedPreferences _prefs;

  // ── Last sync timestamps ──────────────────────────────────────────

  DateTime? getLastSync(String key) {
    final ms = _prefs.getInt('last_sync_$key');
    if (ms == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(ms);
  }

  Future<void> setLastSync(String key, DateTime time) {
    return _prefs.setInt('last_sync_$key', time.millisecondsSinceEpoch);
  }

  // ── Filter preferences ───────────────────────────────────────────

  String? getSelectedFilter(String screen) {
    return _prefs.getString('filter_$screen');
  }

  Future<void> setSelectedFilter(String screen, String value) {
    return _prefs.setString('filter_$screen', value);
  }

  // ── Generic helpers ───────────────────────────────────────────────

  Future<void> clear() => _prefs.clear();
}
