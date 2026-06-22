class HighLowItem {
  final String symbol;
  final String companyName;
  final num? lastPrice;
  final num? previousClose;
  final num? change;
  final num? pChange;
  final num? value52Week;
  final String type;

  HighLowItem({
    required this.symbol,
    required this.companyName,
    this.lastPrice,
    this.previousClose,
    this.change,
    this.pChange,
    this.value52Week,
    required this.type,
  });

  factory HighLowItem.fromJson(Map<String, dynamic> json) {
    return HighLowItem(
      symbol: json['symbol'] ?? '',
      companyName: json['companyName'] ?? '',
      lastPrice: json['lastPrice'],
      previousClose: json['previousClose'],
      change: json['change'],
      pChange: json['pChange'],
      value52Week: json['value52Week'],
      type: json['type'] ?? 'HIGH',
    );
  }
}

class HighLowModel {
  final List<HighLowItem> highs;
  final List<HighLowItem> lows;

  HighLowModel({
    required this.highs,
    required this.lows,
  });

  factory HighLowModel.fromJson(Map<String, dynamic> json) {
    return HighLowModel(
      highs: (json['highs'] as List<dynamic>?)
              ?.map((e) => HighLowItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      lows: (json['lows'] as List<dynamic>?)
              ?.map((e) => HighLowItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
