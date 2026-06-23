import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_enums.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../data/repositories/providers.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_state.dart';
import '../widgets/event_card.dart';
import '../widgets/fade_switcher.dart';
import '../widgets/filter_chip_bar.dart';
import '../widgets/section_header.dart';
import '../widgets/skeleton_loader.dart';

class TimelineScreen extends ConsumerStatefulWidget {
  const TimelineScreen({super.key});

  @override
  ConsumerState<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends ConsumerState<TimelineScreen> {
  int _filterIndex = 0;

  static const _filterLabels = [
    'ALL',
    'DIVIDEND',
    'BONUS',
    'SPLIT',
    'BUYBACK',
    'EARNINGS',
  ];

  @override
  Widget build(BuildContext context) {
    final asyncEvents = ref.watch(timelineEventsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('TIMELINE'),
      ),
      body: Column(
        children: [
          const SizedBox(height: AppSpacing.sm),
          FilterChipBar(
            labels: _filterLabels,
            selectedIndex: _filterIndex,
            onSelected: (index) => setState(() => _filterIndex = index),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: FadeSwitcher(
              child: asyncEvents.when(
                loading: () => Padding(
                  key: const ValueKey('loading'),
                  padding: AppSpacing.screenPadding,
                  child: const SkeletonLoader(itemCount: 6, itemHeight: 64),
                ),
                error: (err, _) => ErrorState(
                  key: const ValueKey('error'),
                  message: 'Failed to load timeline.',
                  onRetry: () {
                    ref.invalidate(corporateActionsProvider);
                    ref.invalidate(earningsCalendarProvider);
                  },
                ),
                data: (events) {
                  // Apply filter
                  final filtered = _filterIndex == 0
                      ? events
                      : events
                          .where((e) =>
                              e.eventType.toUpperCase() ==
                              _filterLabels[_filterIndex])
                          .toList();

                  if (filtered.isEmpty) {
                    return const EmptyState(
                      key: ValueKey('empty'),
                      icon: Icons.timeline,
                      message: 'No events found.',
                    );
                  }

                  // Group by date
                  final grouped = <String, List<TimelineEvent>>{};
                  for (final event in filtered) {
                    final group = event.dateLabel;
                    grouped.putIfAbsent(group, () => []).add(event);
                  }

                  // Events are already sorted by date in provider
                  final orderedKeys = grouped.keys.toList();

                  return ListView.builder(
                    key: const ValueKey('data'),
                    padding: AppSpacing.screenPadding,
                    itemCount: orderedKeys.length,
                    itemBuilder: (context, sectionIndex) {
                      final group = orderedKeys[sectionIndex];
                      final items = grouped[group]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (sectionIndex > 0) AppSpacing.sectionGap,
                          SectionHeader(
                            title: group,
                            trailing: Text(
                              '${items.length}',
                              style: AppTypography.metadata,
                            ),
                          ),
                          ...items.map((event) {
                            final importance = _importanceFromIndex(event.importanceIndex);
                            return EventCard(
                                title: event.entity,
                                subtitle: event.title,
                                date: event.date,
                                importance: importance,
                                source: event.source,
                                dividendAmount: event.dividendAmount,
                            );
                          }),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  ImportanceLevel _importanceFromIndex(int index) {
    switch (index) {
      case 0:
        return ImportanceLevel.critical;
      case 1:
        return ImportanceLevel.high;
      case 2:
        return ImportanceLevel.medium;
      default:
        return ImportanceLevel.low;
    }
  }
}
