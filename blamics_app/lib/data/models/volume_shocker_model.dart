class VolumeShockerModel {
  final String symbol;
  final String name;
  final double? lastPrice;
  final double? changePct;
  final int? volume;
  final double? turnoverCr;
  final double? volChange1WkPct;
  final double? volChange2WkPct;

  VolumeShockerModel({
    required this.symbol,
    required this.name,
    this.lastPrice,
    this.changePct,
    this.volume,
    this.turnoverCr,
    this.volChange1WkPct,
    this.volChange2WkPct,
  });

  factory VolumeShockerModel.fromJson(Map<String, dynamic> json) {
    return VolumeShockerModel(
      symbol: json['symbol'] ?? '',
      name: json['name'] ?? '',
      lastPrice: num.tryParse(json['last_price']?.toString() ?? '')?.toDouble(),
      changePct: num.tryParse(json['change_pct']?.toString() ?? '')?.toDouble(),
      volume: num.tryParse(json['volume']?.toString() ?? '')?.toInt(),
      turnoverCr: num.tryParse(json['turnover_cr']?.toString() ?? '')?.toDouble(),
      volChange1WkPct: num.tryParse(json['vol_change_1wk_pct']?.toString() ?? '')?.toDouble(),
      volChange2WkPct: num.tryParse(json['vol_change_2wk_pct']?.toString() ?? '')?.toDouble(),
    );
  }
}
