/// Source metadata attached to every piece of data.
///
/// Tracks provenance and freshness. Every API response
/// and every cache row carries this.
class SourceMeta {
  const SourceMeta({
    required this.sourceId,
    required this.sourcePriority,
    required this.createdAt,
    required this.fetchedAt,
    this.updatedAt,
  });

  /// ID of the data source (e.g., "nse", "bse", "chittorgarh").
  final String sourceId;

  /// Priority level: "official", "secondary", "unofficial".
  final String sourcePriority;

  /// When this data first entered our system.
  final DateTime createdAt;

  /// When this data was last fetched from the source.
  final DateTime fetchedAt;

  /// When the source itself last updated this data (if known).
  final DateTime? updatedAt;

  /// Human-readable priority label.
  String get priorityLabel => switch (sourcePriority) {
    'official' => 'Official',
    'secondary' => 'Secondary',
    'unofficial' => 'Unofficial',
    _ => 'Unknown',
  };

  /// Whether this source is unofficial.
  bool get isUnofficial => sourcePriority == 'unofficial';

  factory SourceMeta.fromJson(Map<String, dynamic> json) {
    return SourceMeta(
      sourceId: json['source_id'] as String? ?? json['source'] as String, // Fallback for old cache
      sourcePriority: json['source_priority'] as String? ?? 'secondary',
      createdAt: DateTime.parse(json['created_at'] as String? ?? json['fetched_at'] as String), // Fallback
      fetchedAt: DateTime.parse(json['fetched_at'] as String),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'source_id': sourceId,
      'source_priority': sourcePriority,
      'created_at': createdAt.toIso8601String(),
      'fetched_at': fetchedAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
