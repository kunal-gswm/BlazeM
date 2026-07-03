class CurrencyModel {
  final String symbol;
  final String name;
  final double? rate;
  final double? change;
  final double? changePct;

  CurrencyModel({
    required this.symbol,
    required this.name,
    this.rate,
    this.change,
    this.changePct,
  });

  factory CurrencyModel.fromJson(Map<String, dynamic> json) {
    return CurrencyModel(
      symbol: json['symbol'] ?? '',
      name: json['name'] ?? '',
      rate: num.tryParse(json['rate']?.toString() ?? '')?.toDouble(),
      change: num.tryParse(json['change']?.toString() ?? '')?.toDouble(),
      changePct: num.tryParse(json['change_pct']?.toString() ?? '')?.toDouble(),
    );
  }
}
