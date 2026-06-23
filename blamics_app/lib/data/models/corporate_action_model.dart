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
      dividendAmount: num.tryParse(json['dividend_amount']?.toString() ?? '')?.toDouble(),
    );
  }

  String get cleanPurpose {
    // Remove variations like "- Rs. - 15.0000", "- Rs 15.00", "Rs. 15" from the end of the string
    return purpose.replaceAll(RegExp(r'\s*-?\s*Rs\.?\s*-?\s*[\d.]+$', caseSensitive: false), '').trim();
  }
}
