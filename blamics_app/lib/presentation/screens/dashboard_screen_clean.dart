import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../data/repositories/providers.dart';
import '../widgets/fade_switcher.dart';
import '../widgets/section_header.dart';
import '../widgets/skeleton_loader.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BLAMICS'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            onPressed: () {
              ref.invalidate(corporateActionsProvider);
              ref.invalidate(fiiDiiDataProvider);
              ref.invalidate(globalIndicesProvider);
              ref.invalidate(marketBreadthProvider);
              ref.invalidate(earningsCalendarProvider);
              ref.invalidate(criticalTodayProvider);
              ref.invalidate(upcoming7DaysProvider);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(corporateActionsProvider);
          ref.invalidate(fiiDiiDataProvider);
          ref.invalidate(globalIndicesProvider);
          ref.invalidate(marketBreadthProvider);
          ref.invalidate(earningsCalendarProvider);
        },
        color: AppColors.primary,
        backgroundColor: AppColors.surface1,
        child: ListView(
          padding: AppSpacing.screenPadding,
          children: const [
            _MarketSnapshotSection(),
            SizedBox(height: AppSpacing.xl),
            _HighlightsSection(),
            SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}


// ── Market Snapshot ──────────────────────────────────────────────────────────

class _MarketSnapshotSection extends ConsumerWidget {
  const _MarketSnapshotSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        SectionHeader(title: 'Market Snapshot'),
        _MarketBreadthRow(),
        AppSpacing.itemGap,
        _FiiDiiRow(),
        AppSpacing.itemGap,
        _GlobalIndicesMini(),
      ],
    );
  }
}

class _MarketBreadthRow extends ConsumerWidget {
  const _MarketBreadthRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(marketBreadthProvider);

    return FadeSwitcher(
      child: asyncData.when(
        loading: () =>
            const SkeletonLoader(key: ValueKey('loading'), itemCount: 1, itemHeight: 64),
        error: (err, stack) => const SizedBox.shrink(key: ValueKey('error')),
        data: (response) {
          if (response.data.isEmpty) {
            return const SizedBox.shrink(key: ValueKey('empty'));
          }
          final breadth = response.data.first;
          final advances = (breadth.up ?? breadth.advance ?? 0).toInt();
          final declines = (breadth.dn ?? breadth.decline ?? 0).toInt();

          return Container(
            key: const ValueKey('data'),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface1,
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              border: Border.all(color: AppColors.border, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    _BreadthStat(label: 'ADV', value: '$advances', color: AppColors.success),
                    const SizedBox(width: AppSpacing.lg),
                    _BreadthStat(label: 'DEC', value: '$declines', color: AppColors.danger),
                    const Spacer(),
                    Text(
                      breadth.sensInd ?? '',
                      style: AppTypography.timestamp,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: SizedBox(
                    height: 4,
                    child: Row(
                      children: [
                        if (advances > 0)
                          Expanded(
                            flex: advances,
                            child: Container(color: AppColors.success),
                          ),
                        if (declines > 0)
                          Expanded(
                            flex: declines,
                            child: Container(color: AppColors.danger),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BreadthStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _BreadthStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          label,
          style: AppTypography.metadata.copyWith(color: color),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          value,
          style: AppTypography.value.copyWith(
            color: color,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _FiiDiiRow extends ConsumerWidget {
  const _FiiDiiRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(fiiDiiDataProvider);

    return FadeSwitcher(
      child: asyncData.when(
        loading: () =>
            const SkeletonLoader(key: ValueKey('loading'), itemCount: 1, itemHeight: 70),
        error: (err, stack) => const SizedBox.shrink(key: ValueKey('error')),
        data: (response) {
          if (response.data.isEmpty) {
            return const SizedBox.shrink(key: ValueKey('empty'));
          }
          return Row(
            key: const ValueKey('data'),
            children: [
              for (var i = 0; i < 2 && i < response.data.length; i++) ...[
                if (i > 0) const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surface1,
                      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                      border: Border.all(color: AppColors.border, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          response.data[i].category ?? '',
                          style: AppTypography.metadata.copyWith(fontSize: 12),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${(response.data[i].netValue ?? 0) >= 0 ? '+' : ''}${response.data[i].netValue?.toStringAsFixed(2) ?? '0.00'} Cr',
                          style: AppTypography.value.copyWith(
                            color: (response.data[i].netValue ?? 0) >= 0 ? AppColors.success : AppColors.danger,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _GlobalIndicesMini extends ConsumerWidget {
  const _GlobalIndicesMini();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(globalIndicesProvider);

    return FadeSwitcher(
      child: asyncData.when(
        loading: () =>
            const SkeletonLoader(key: ValueKey('loading'), itemCount: 3, itemHeight: 36),
        error: (err, stack) => const SizedBox.shrink(key: ValueKey('error')),
        data: (response) {
          if (response.data.isEmpty) {
            return const SizedBox.shrink(key: ValueKey('empty'));
          }
          return Container(
            key: const ValueKey('data'),
            padding: AppSpacing.cardPadding,
            decoration: BoxDecoration(
              color: AppColors.surface1,
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              border: Border.all(color: AppColors.border, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: response.data.take(4).map((index) {
                final isPositive = (index.changePct ?? 0) >= 0;
                final color = isPositive ? AppColors.success : AppColors.danger;
                final sign = isPositive ? '+' : '';

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          index.name.toUpperCase().replaceAll(' BSE ', ' '),
                          style: AppTypography.metadata,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        index.price?.toStringAsFixed(2) ?? '-',
                        style: AppTypography.bodyMedium.copyWith(fontSize: 13),
                      ),
                      SizedBox(
                        width: 64,
                        child: Text(
                          '$sign${index.changePct?.toStringAsFixed(2) ?? '0.00'}%',
                          style: AppTypography.bodyMedium.copyWith(
                            color: color,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}

 
 

// ── Highlights ──────────────────────────────────────────────────────────────

class _HighlightsSection extends ConsumerWidget {
  const _HighlightsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncEvents = ref.watch(timelineEventsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Upcoming Highlights'),
        SizedBox(
          height: 120,
          child: asyncEvents.when(
            loading: () => ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (_, __) => const SizedBox(
                width: 200,
                child: SkeletonLoader(itemCount: 1, itemHeight: 120),
              ),
            ),
            error: (_, __) => const SizedBox.shrink(),
            data: (events) {
              final highlights = events.where((e) {
                if (e.parsedDate == null) return false;
                return e.parsedDate!.isAfter(DateTime.now().subtract(const Duration(days: 1))) &&
                    (e.importanceIndex == 0 || e.importanceIndex == 1);
              }).take(5).toList();

              if (highlights.isEmpty) {
                return Center(
                  child: Text('No major upcoming events.', style: AppTypography.bodySecondary),
                );
              }

              return ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: highlights.length,
                separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final event = highlights[index];
                  return Container(
                    width: 220,
                    padding: AppSpacing.cardPadding,
                    decoration: BoxDecoration(
                      color: AppColors.surface1,
                      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                      border: Border.all(color: AppColors.border, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.surface2,
                            borderRadius: BorderRadius.circular(AppSpacing.badgeRadius),
                          ),
                          child: Text(
                            event.eventType.toUpperCase(),
                            style: AppTypography.metadata.copyWith(fontSize: 10),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          event.entity,
                          style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          event.title,
                          style: AppTypography.bodySecondary.copyWith(fontSize: 12),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        Text(
                          event.date ?? '',
                          style: AppTypography.timestamp.copyWith(color: AppColors.primary),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
