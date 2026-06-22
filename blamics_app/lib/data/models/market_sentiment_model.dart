class MarketSentimentModel {
  final num score;
  final String label;
  final String? timestamp;

  MarketSentimentModel({
    required this.score,
    required this.label,
    this.timestamp,
  });

  factory MarketSentimentModel.fromJson(Map<String, dynamic> json) {
    return MarketSentimentModel(
      score: json['score'] ?? 50.0,
      label: json['label'] ?? 'Neutral',
      timestamp: json['timestamp'],
    );
  }
}
