import 'package:intl/intl.dart';

class EarningsCalendarModel {
  final dynamic scripCode;
  final String shortName;
  final String longName;
  final String? meetingDate;
  final String? url;

  EarningsCalendarModel({
    required this.scripCode,
    required this.shortName,
    required this.longName,
    this.meetingDate,
    this.url,
  });

  static String? _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    try {
      final parsed = DateFormat('dd MMM yyyy').parse(dateStr);
      return DateFormat('dd MMMM yyyy').format(parsed);
    } catch (_) {
      try {
        final parsed = DateTime.parse(dateStr);
        return DateFormat('dd MMMM yyyy').format(parsed);
      } catch (_) {
        return dateStr;
      }
    }
  }

  factory EarningsCalendarModel.fromJson(Map<String, dynamic> json) {
    return EarningsCalendarModel(
      scripCode: json['scrip_Code'] ?? json['scrip_code'],
      shortName: json['short_name'] ?? '',
      longName: json['Long_Name'] ?? json['long_name'] ?? '',
      meetingDate: _formatDate(json['meeting_date']),
      url: json['URL'] ?? json['url'],
    );
  }
}
