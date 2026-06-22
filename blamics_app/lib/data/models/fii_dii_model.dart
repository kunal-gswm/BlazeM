class FiiDiiModel {
  final String category;
  final String date;
  final double? buyValue;
  final double? sellValue;
  final double? netValue;

  FiiDiiModel({
    required this.category,
    required this.date,
    this.buyValue,
    this.sellValue,
    this.netValue,
  });

  factory FiiDiiModel.fromJson(Map<String, dynamic> json) {
    return FiiDiiModel(
      category: json['category'] ?? '',
      date: json['date'] ?? '',
      buyValue: (json['buyValue'] as num?)?.toDouble(),
      sellValue: (json['sellValue'] as num?)?.toDouble(),
      netValue: (json['netValue'] as num?)?.toDouble(),
    );
  }
}
