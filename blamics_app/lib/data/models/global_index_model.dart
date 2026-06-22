class GlobalIndexModel {
  final String symbol;
  final String name;
  final double? price;
  final double? change;
  final double? changePct;

  GlobalIndexModel({
    required this.symbol,
    required this.name,
    this.price,
    this.change,
    this.changePct,
  });

  factory GlobalIndexModel.fromJson(Map<String, dynamic> json) {
    return GlobalIndexModel(
      symbol: json['symbol'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] as num?)?.toDouble(),
      change: (json['change'] as num?)?.toDouble(),
      changePct: (json['change_pct'] as num?)?.toDouble(),
    );
  }
}
