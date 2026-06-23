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
      buyValue: num.tryParse(json['buyValue']?.toString() ?? '')?.toDouble(),
      sellValue: num.tryParse(json['sellValue']?.toString() ?? '')?.toDouble(),
      netValue: num.tryParse(json['netValue']?.toString() ?? '')?.toDouble(),
    );
  }
}
