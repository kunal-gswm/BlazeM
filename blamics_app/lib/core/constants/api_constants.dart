class ApiConstants {
  static const String baseUrl = 'https://raw.githubusercontent.com/kunal-gswm/BlazeM/main';

  static const String ipoData = '$baseUrl/data/ipo_data.json';
  static const String fiiDiiData = '$baseUrl/data/fii_dii.json';
  static const String corporateActions = '$baseUrl/data/corporate_actions.json';
  static const String earningsCalendar = '$baseUrl/data/earnings_calendar.json';
  static const String marketBreadth = '$baseUrl/data/market_breadth.json';
  static const String globalIndices = '$baseUrl/data/global_indices.json';
  static const String health = '$baseUrl/data/health.json';

  // New Live Data Endpoints
  static const String sectorPerformance = '$baseUrl/data/sector_performance.json';
  static const String marketSentiment = '$baseUrl/data/market_sentiment.json';
  static const String highLow = '$baseUrl/data/high_low.json';
}
