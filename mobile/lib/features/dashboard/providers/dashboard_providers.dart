import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/data_state.dart';
import '../../../core/models/timeline_event.dart';
import '../../../core/services/api_service.dart';

/// Provides the current state of timeline events for the dashboard.
final dashboardEventsProvider = FutureProvider<DataState<List<TimelineEvent>>>((ref) async {
  final service = ref.watch(apiServiceProvider);
  final result = await service.getTimelineEvents();
  
  return result.when(
    success: (events) => DataState.fresh(events, DateTime.now()),
    failure: (failure) => DataState.error(failure.message),
  );
});
