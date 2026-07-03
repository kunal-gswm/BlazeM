class ApiMetadata {
  final String source;
  final String lastUpdated;
  final String status;
  final int recordCount;

  ApiMetadata({
    required this.source,
    required this.lastUpdated,
    required this.status,
    required this.recordCount,
  });

  factory ApiMetadata.fromJson(Map<String, dynamic> json) {
    return ApiMetadata(
      source: json['source'] ?? '',
      lastUpdated: json['last_updated'] ?? '',
      status: json['status'] ?? 'unknown',
      recordCount: json['record_count'] ?? 0,
    );
  }
}

class ApiResponse<T> {
  final ApiMetadata metadata;
  final List<T> data;

  ApiResponse({
    required this.metadata,
    required this.data,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final rawData = json['data'];
    List<T> parsedData = [];
    if (rawData is List) {
      parsedData = rawData
          .map((item) => fromJsonT(item as Map<String, dynamic>))
          .toList();
    } else if (rawData is Map<String, dynamic>) {
      parsedData = [fromJsonT(rawData)];
    } else if (rawData is Map) {
      parsedData = [fromJsonT(Map<String, dynamic>.from(rawData))];
    }

    return ApiResponse(
      metadata: ApiMetadata.fromJson(json['metadata'] ?? {}),
      data: parsedData,
    );
  }
}
