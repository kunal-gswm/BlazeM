import '../../../core/models/source_meta.dart';
import '../../../core/models/timeline_event.dart'; // For EventStatus

class IpoModel {
  const IpoModel({
    required this.id,
    required this.companyName,
    required this.symbol,
    required this.issuePriceMin,
    required this.issuePriceMax,
    required this.lotSize,
    required this.issueSize,
    required this.retailQuota,
    required this.status,
    required this.openDate,
    required this.closeDate,
    required this.allotmentDate,
    required this.listingDate,
    required this.meta,
  });

  final String id;
  final String companyName;
  final String? symbol;
  final double? issuePriceMin;
  final double? issuePriceMax;
  final int? lotSize;
  final double? issueSize;
  final double? retailQuota;
  final EventStatus status;
  final DateTime? openDate;
  final DateTime? closeDate;
  final DateTime? allotmentDate;
  final DateTime? listingDate;
  final SourceMeta meta;

  factory IpoModel.fromJson(Map<String, dynamic> json) {
    return IpoModel(
      id: json['id'] as String,
      companyName: json['company_name'] as String,
      symbol: json['symbol'] as String?,
      issuePriceMin: (json['issue_price_min'] as num?)?.toDouble(),
      issuePriceMax: (json['issue_price_max'] as num?)?.toDouble(),
      lotSize: json['lot_size'] as int?,
      issueSize: (json['issue_size'] as num?)?.toDouble(),
      retailQuota: (json['retail_quota'] as num?)?.toDouble(),
      status: EventStatus.values.byName(json['status'] as String),
      openDate: json['open_date'] != null ? DateTime.parse(json['open_date'] as String) : null,
      closeDate: json['close_date'] != null ? DateTime.parse(json['close_date'] as String) : null,
      allotmentDate: json['allotment_date'] != null ? DateTime.parse(json['allotment_date'] as String) : null,
      listingDate: json['listing_date'] != null ? DateTime.parse(json['listing_date'] as String) : null,
      meta: SourceMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );
  }
}
