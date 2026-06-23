class MarketBreadthModel {
  final num? advance;
  final num? advancePer;
  final num? decline;
  final num? declinePer;
  final num? unchange;
  final num? unchangePer;
  final num? total;
  final String? scripGrp;
  final String? sensInd;
  final num? up;
  final num? dn;
  final num? uc;

  MarketBreadthModel({
    this.advance,
    this.advancePer,
    this.decline,
    this.declinePer,
    this.unchange,
    this.unchangePer,
    this.total,
    this.scripGrp,
    this.sensInd,
    this.up,
    this.dn,
    this.uc,
  });

  factory MarketBreadthModel.fromJson(Map<String, dynamic> json) {
    return MarketBreadthModel(
      advance: num.tryParse(json['Advance']?.toString() ?? ''),
      advancePer: num.tryParse(json['Advance_PER']?.toString() ?? ''),
      decline: num.tryParse(json['Decline']?.toString() ?? ''),
      declinePer: num.tryParse(json['Decline_PER']?.toString() ?? ''),
      unchange: num.tryParse(json['Unchange']?.toString() ?? ''),
      unchangePer: num.tryParse(json['Unchange_PER']?.toString() ?? ''),
      total: num.tryParse(json['TOTAL']?.toString() ?? ''),
      scripGrp: json['Scrip_GRP'] as String?,
      sensInd: json['Sens_ind'] as String?,
      up: num.tryParse(json['UP']?.toString() ?? ''),
      dn: num.tryParse(json['DN']?.toString() ?? ''),
      uc: num.tryParse(json['UC']?.toString() ?? ''),
    );
  }
}
