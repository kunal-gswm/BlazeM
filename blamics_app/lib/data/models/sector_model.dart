class SectorModel {
  final String symbol;
  final num? lastPrice;
  final num? percentChange;
  final num? change;
  final String status;

  SectorModel({
    required this.symbol,
    this.lastPrice,
    this.percentChange,
    this.change,
    required this.status,
  });

  factory SectorModel.fromJson(Map<String, dynamic> json) {
    return SectorModel(
      symbol: json['symbol']?.toString() ?? '',
      lastPrice: num.tryParse(json['lastPrice']?.toString() ?? ''),
      percentChange: num.tryParse(json['percentChange']?.toString() ?? ''),
      change: num.tryParse(json['change']?.toString() ?? ''),
      status: json['status']?.toString() ?? 'flat',
    );
  }
}
