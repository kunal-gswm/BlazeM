import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/data_state.dart';
import '../../../core/models/timeline_event.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/cache_service.dart';

/// Provides the current state of timeline events for the dashboard.
final dashboardEventsProvider = FutureProvider<DataState<List<TimelineEvent>>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  final cacheService = ref.watch(cacheServiceProvider);
  
  final result = await apiService.getTimelineEvents();
  
  return result.when(
    success: (events) {
      // In a real scenario, the apiService would save this to cache.
      // For now we just return fresh.
      return DataState.fresh(events, DateTime.now());
    },
    failure: (failure) async {
      // Fallback to cache on error
      final cachedEvents = await cacheService.getTimelineEvents();
      if (cachedEvents != null && cachedEvents.isNotEmpty) {
        return DataState.stale(cachedEvents, DateTime.now().subtract(const Duration(hours: 2)));
      }
      return DataState.error(failure.toString());
    },
  );
});
