class CircuitBreakerItem {
  final String symbol;
  final String name;
  final double? lastPrice;
  final double? prevClose;
  final double? change;
  final double? changePct;
  final int? volume;
  final double? turnoverCr;

  CircuitBreakerItem({
    required this.symbol,
    required this.name,
    this.lastPrice,
    this.prevClose,
    this.change,
    this.changePct,
    this.volume,
    this.turnoverCr,
  });

  factory CircuitBreakerItem.fromJson(Map<String, dynamic> json) {
    return CircuitBreakerItem(
      symbol: json['symbol'] ?? '',
      name: json['name'] ?? '',
      lastPrice: num.tryParse(json['last_price']?.toString() ?? '')?.toDouble(),
      prevClose: num.tryParse(json['prev_close']?.toString() ?? '')?.toDouble(),
      change: num.tryParse(json['change']?.toString() ?? '')?.toDouble(),
      changePct: num.tryParse(json['change_pct']?.toString() ?? '')?.toDouble(),
      volume: num.tryParse(json['volume']?.toString() ?? '')?.toInt(),
      turnoverCr: num.tryParse(json['turnover_cr']?.toString() ?? '')?.toDouble(),
    );
  }
}

class CircuitBreakerModel {
  final List<CircuitBreakerItem> upperCircuit;
  final List<CircuitBreakerItem> lowerCircuit;

  CircuitBreakerModel({
    required this.upperCircuit,
    required this.lowerCircuit,
  });

  factory CircuitBreakerModel.fromJson(Map<String, dynamic> json) {
    final upperList = (json['upper_circuit'] as List?)
            ?.map((e) => CircuitBreakerItem.fromJson(Map<String, dynamic>.from(e)))
            .toList() ??
        [];
    final lowerList = (json['lower_circuit'] as List?)
            ?.map((e) => CircuitBreakerItem.fromJson(Map<String, dynamic>.from(e)))
            .toList() ??
        [];
    return CircuitBreakerModel(
      upperCircuit: upperList,
      lowerCircuit: lowerList,
    );
  }
}
