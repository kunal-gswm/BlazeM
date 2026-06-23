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
      issueName: json['issue_name']?.toString() ?? '',
      ipoType: json['ipo_type']?.toString() ?? '',
      source: json['source']?.toString() ?? '',
      priceBand: json['price_band']?.toString() ?? '',
      lotSize: json['lot_size']?.toString() ?? '',
      issueSize: json['issue_size']?.toString() ?? '',
      issueOpen: json['issue_open']?.toString(),
      issueClose: json['issue_close']?.toString(),
      allotmentDate: json['allotment_date']?.toString(),
      listingDate: json['listing_date']?.toString(),
      gmp: num.tryParse(json['gmp']?.toString() ?? '')?.toDouble(),
      gmpPercent: json['gmp_percent']?.toString(),
    );
  }

  String get calculatedGmpPercent {
    if (gmpPercent != null && gmpPercent!.isNotEmpty) return gmpPercent!;
    if (gmp == null || gmp == 0) return '0.00%';
    
    double? price;
    if (priceBand.contains('-')) {
      final parts = priceBand.split('-');
      price = double.tryParse(parts.last.replaceAll(RegExp(r'[^0-9.]'), ''));
    } else {
      price = double.tryParse(priceBand.replaceAll(RegExp(r'[^0-9.]'), ''));
    }
    
    if (price != null && price > 0) {
      final pct = (gmp! / price) * 100;
      return '${pct.toStringAsFixed(2)}%';
    }
    return 'N/A';
  }
}
