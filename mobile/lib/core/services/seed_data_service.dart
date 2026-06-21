import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../error/result.dart';
import '../error/failures.dart';
import '../models/timeline_event.dart';
import '../../features/ipo/models/ipo_model.dart';

/// Provider for the mock offline data service.
final seedDataServiceProvider = Provider<SeedDataService>((ref) {
  return SeedDataService();
});

/// Mock service that loads seed_data.json to simulate backend responses.
///
/// This bypasses Dio entirely for Milestone 2.
class SeedDataService {
  Map<String, dynamic>? _cache;

  Future<Map<String, dynamic>> _getRawData() async {
    if (_cache != null) return _cache!;
    final jsonString = await rootBundle.loadString('assets/data/seed_data.json');
    _cache = jsonDecode(jsonString) as Map<String, dynamic>;
    return _cache!;
  }

  Future<Result<List<TimelineEvent>>> getTimelineEvents() async {
    try {
      final data = await _getRawData();
      final eventsJson = data['timeline_events'] as List<dynamic>;
      final events = eventsJson
          .map((e) => TimelineEvent.fromJson(e as Map<String, dynamic>))
          .toList();
      
      // Sort by date ascending for timeline
      events.sort((a, b) => a.date.compareTo(b.date));
      return Success(events);
    } catch (e, st) {
      return Err(UnexpectedFailure(e));
    }
  }

  Future<Result<List<IpoModel>>> getIpos() async {
    try {
      final data = await _getRawData();
      final iposJson = data['ipos'] as List<dynamic>;
      final ipos = iposJson
          .map((e) => IpoModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return Success(ipos);
    } catch (e, st) {
      return Err(UnexpectedFailure(e));
    }
  }
}
