class CorporateActionModel {
  final dynamic scripCode;
  final String shortName;
  final String longName;
  final String? exDate;
  final String purpose;
  final String actionType;
  final double? dividendAmount;

  CorporateActionModel({
    required this.scripCode,
    required this.shortName,
    required this.longName,
    this.exDate,
    required this.purpose,
    required this.actionType,
    this.dividendAmount,
  });

  factory CorporateActionModel.fromJson(Map<String, dynamic> json) {
    return CorporateActionModel(
      scripCode: json['scrip_code'],
      shortName: json['short_name'] ?? '',
      longName: json['long_name'] ?? '',
      exDate: json['Ex_date'],
      purpose: json['Purpose'] ?? '',
      actionType: json['action_type'] ?? '',
      dividendAmount: (json['dividend_amount'] as num?)?.toDouble(),
    );
  }
}
