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

  factory EarningsCalendarModel.fromJson(Map<String, dynamic> json) {
    return EarningsCalendarModel(
      scripCode: json['scrip_Code'] ?? json['scrip_code'],
      shortName: json['short_name'] ?? '',
      longName: json['Long_Name'] ?? json['long_name'] ?? '',
      meetingDate: json['meeting_date'],
      url: json['URL'] ?? json['url'],
    );
  }
}
