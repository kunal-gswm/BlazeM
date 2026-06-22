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
            const SkeletonLoader(key: ValueKey('loading'), itemCount: 1, itemHeight: 56),
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
            padding: AppSpacing.cardPadding,
            decoration: BoxDecoration(
              color: AppColors.surface1,
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              border: Border.all(color: AppColors.border, width: 1),
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
                const SizedBox(height: AppSpacing.sm),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: SizedBox(
                    height: 3,
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
      children: [
        Text(
          label,
          style: AppTypography.metadata.copyWith(color: color),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          value,
          style: AppTypography.value.copyWith(color: color),
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
            const SkeletonLoader(key: ValueKey('loading'), itemCount: 1, itemHeight: 48),
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
            ),
            child: Row(
              children: response.data.take(2).map((item) {
                final isPositive = (item.netValue ?? 0) >= 0;
                final color = isPositive ? AppColors.success : AppColors.danger;
                final sign = isPositive ? '+' : '';

                return Expanded(
                  child: Row(
                    children: [
                      Text(
                        '${item.category} ',
                        style: AppTypography.metadata,
                      ),
                      Text(
                        '$sign${item.netValue?.toStringAsFixed(2) ?? '0.00'} Cr',
                        style: AppTypography.value.copyWith(color: color, fontSize: 13),
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
