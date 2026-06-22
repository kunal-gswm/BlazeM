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
      symbol: json['symbol'] ?? '',
      lastPrice: json['lastPrice'],
      percentChange: json['percentChange'],
      change: json['change'],
      status: json['status'] ?? 'flat',
    );
  }
}
