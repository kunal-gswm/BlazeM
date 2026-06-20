/// Source metadata attached to every piece of data.
///
/// Tracks provenance and freshness. Every API response
/// and every cache row carries this.
class SourceMeta {
  const SourceMeta({
    required this.source,
    required this.sourcePriority,
    required this.fetchedAt,
    required this.updatedAt,
  });

  /// Name of the data source (e.g., "BSE", "Chittorgarh", "GMP Tracker").
  final String source;

  /// Priority level: 1 = official, 2 = secondary, 3 = unofficial.
  final int sourcePriority;

  /// When this data was fetched from the source.
  final DateTime fetchedAt;

  /// When the source last updated this data.
  final DateTime updatedAt;

  /// Human-readable priority label.
  String get priorityLabel => switch (sourcePriority) {
    1 => 'Official',
    2 => 'Secondary',
    3 => 'Unofficial',
    _ => 'Unknown',
  };

  /// Whether this source is unofficial (P3).
  bool get isUnofficial => sourcePriority >= 3;

  factory SourceMeta.fromJson(Map<String, dynamic> json) {
    return SourceMeta(
      source: json['source'] as String,
      sourcePriority: json['source_priority'] as int? ?? 2,
      fetchedAt: DateTime.parse(json['fetched_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'source': source,
      'source_priority': sourcePriority,
      'fetched_at': fetchedAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
