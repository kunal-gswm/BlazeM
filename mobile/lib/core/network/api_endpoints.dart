/// Centralized API endpoint constants.
///
/// No magic strings in service files.
class ApiEndpoints {
  const ApiEndpoints._();

  // Dashboard
  static const String dashboard = '/dashboard';

  // IPOs
  static const String ipos = '/ipos';
  static String ipoDetail(String id) => '/ipos/$id';
  static String ipoGmp(String id) => '/ipos/$id/gmp';

  // Corporate actions
  static const String corporateActions = '/corporate-actions';
  static String corporateActionDetail(String id) => '/corporate-actions/$id';

  // Bonds
  static const String bonds = '/bonds';
  static String bondDetail(String id) => '/bonds/$id';

  // News
  static const String news = '/news';
  static String newsDetail(String id) => '/news/$id';

  // Watchlist
  static const String watchlist = '/watchlist';
  static String watchlistItem(String eventId) => '/watchlist/$eventId';

  // Search
  static const String search = '/search';

  // Events / Timeline
  static const String eventsTimeline = '/events/timeline';
  static String eventTimeline(String id) => '/events/$id/timeline';
}
