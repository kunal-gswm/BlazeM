import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/data_state.dart';
import '../../../core/models/timeline_event.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/shimmer_loader.dart';
import '../../../core/widgets/event_timeline_card.dart';
import '../../dashboard/providers/dashboard_providers.dart'; // Re-use the provider for MVP

class EventTimelineScreen extends ConsumerWidget {
  const EventTimelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // For MVP, we can reuse dashboardEventsProvider since both read from SeedDataService.getTimelineEvents().
    final stateAsync = ref.watch(dashboardEventsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Timeline'),
      ),
      body: stateAsync.when(
        data: (state) => _buildBody(context, state),
        error: (err, _) => ErrorView(
          message: err.toString(),
          onRetry: () => ref.invalidate(dashboardEventsProvider),
        ),
        loading: () => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: 10,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (_, _) => ShimmerLoader.block(height: 120),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, DataState<List<TimelineEvent>> state) {
    return switch (state) {
      DataLoading() => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: 10,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (_, _) => ShimmerLoader.block(height: 120),
        ),
      DataError(:final message) => ErrorView(message: message),
      DataFresh(:final data) || DataStale(:final data) => _buildList(context, data),
    };
  }

  Widget _buildList(BuildContext context, List<TimelineEvent> events) {
    if (events.isEmpty) {
      return const Center(child: Text('No timeline events.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: events.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return EventTimelineCard(event: events[index]);
      },
    );
  }
}
