class IpoModel {
  final String issueName;
  final String ipoType;
  final String source;
  final String priceBand;
  final String lotSize;
  final String issueSize;
  final String? issueOpen;
  final String? issueClose;
  final String? allotmentDate;
  final String? listingDate;
  final double? gmp;
  final String? gmpPercent;

  IpoModel({
    required this.issueName,
    required this.ipoType,
    required this.source,
    required this.priceBand,
    required this.lotSize,
    required this.issueSize,
    this.issueOpen,
    this.issueClose,
    this.allotmentDate,
    this.listingDate,
    this.gmp,
    this.gmpPercent,
  });

  factory IpoModel.fromJson(Map<String, dynamic> json) {
    return IpoModel(
      issueName: json['issue_name'] ?? '',
      ipoType: json['ipo_type'] ?? '',
      source: json['source'] ?? '',
      priceBand: json['price_band'] ?? '',
      lotSize: json['lot_size'] ?? '',
      issueSize: json['issue_size'] ?? '',
      issueOpen: json['issue_open'],
      issueClose: json['issue_close'],
      allotmentDate: json['allotment_date'],
      listingDate: json['listing_date'],
      gmp: (json['gmp'] as num?)?.toDouble(),
      gmpPercent: json['gmp_percent'],
    );
  }
}
