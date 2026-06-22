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
      advance: json['Advance'] as num?,
      advancePer: json['Advance_PER'] as num?,
      decline: json['Decline'] as num?,
      declinePer: json['Decline_PER'] as num?,
      unchange: json['Unchange'] as num?,
      unchangePer: json['Unchange_PER'] as num?,
      total: json['TOTAL'] as num?,
      scripGrp: json['Scrip_GRP'] as String?,
      sensInd: json['Sens_ind'] as String?,
      up: json['UP'] as num?,
      dn: json['DN'] as num?,
      uc: json['UC'] as num?,
    );
  }
}
