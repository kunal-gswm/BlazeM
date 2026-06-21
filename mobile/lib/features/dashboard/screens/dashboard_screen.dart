import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/data_state.dart';
import '../../../core/models/timeline_event.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/shimmer_loader.dart';
import '../../../core/widgets/event_timeline_card.dart';
import '../../../core/extensions/date_extensions.dart';
import '../providers/dashboard_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(dashboardEventsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Market Events'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(dashboardEventsProvider),
          ),
        ],
      ),
      body: stateAsync.when(
        data: (state) => _buildBody(context, state),
        error: (err, st) => ErrorView(
          message: err.toString(),
          onRetry: () => ref.invalidate(dashboardEventsProvider),
        ),
        loading: () => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: 5,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, __) => ShimmerLoader.block(height: 120),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, DataState<List<TimelineEvent>> state) {
    return switch (state) {
      DataLoading() => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: 5,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, __) => ShimmerLoader.block(height: 120),
        ),
      DataError(:final message) => ErrorView(message: message),
      DataFresh(:final data) || DataStale(:final data) => _buildDashboardContent(context, data),
    };
  }

  Widget _buildDashboardContent(BuildContext context, List<TimelineEvent> events) {
    final highPriorityEvents = events.where((e) => e.importanceScore >= 50).toList();

    if (highPriorityEvents.isEmpty) {
      return const Center(child: Text('No critical or high priority events.'));
    }

    final todayEvents = highPriorityEvents.where((e) => e.date.isToday).toList();
    final upcomingEvents = highPriorityEvents.where((e) => !e.date.isToday).toList();

    return RefreshIndicator(
      onRefresh: () async {
        // Just invalidating for MVP
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (todayEvents.isNotEmpty) ...[
            Text(
              'TODAY',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.textSecondary,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            ...todayEvents.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: EventTimelineCard(event: e),
                )),
            const SizedBox(height: 24),
          ],
          if (upcomingEvents.isNotEmpty) ...[
            Text(
              'UPCOMING',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.textSecondary,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            ...upcomingEvents.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: EventTimelineCard(event: e),
                )),
          ],
        ],
      ),
    );
  }
}
