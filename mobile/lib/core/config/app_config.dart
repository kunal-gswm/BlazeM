/// Application configuration.
///
/// Single source of truth for base URL, timeouts, and cache TTLs.
class AppConfig {
  const AppConfig._();

  /// Backend base URL.
  static const String baseUrl = 'http://localhost:8000/api';

  /// HTTP timeouts.
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);

  /// Cache TTLs — how long before data is considered stale.
  static const Duration dashboardTtl = Duration(minutes: 5);
  static const Duration ipoListTtl = Duration(minutes: 10);
  static const Duration ipoDetailTtl = Duration(minutes: 10);
  static const Duration gmpTtl = Duration(minutes: 15);
  static const Duration corporateActionsTtl = Duration(minutes: 30);
  static const Duration bondsTtl = Duration(minutes: 30);
  static const Duration newsTtl = Duration(minutes: 5);

  /// Database name.
  static const String dbName = 'blamics_cache.db';

  /// Database version.
  static const int dbVersion = 1;
}
