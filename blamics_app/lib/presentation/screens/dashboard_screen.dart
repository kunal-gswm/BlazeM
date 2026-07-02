import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_enums.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../data/repositories/providers.dart';
import '../widgets/event_card.dart';
import '../widgets/fade_switcher.dart';
import '../widgets/section_header.dart';
import '../widgets/skeleton_loader.dart';
import '../widgets/fear_greed_gauge_widget.dart';
import '../widgets/stale_banner.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(corporateActionsProvider);
            ref.invalidate(fiiDiiDataProvider);
            ref.invalidate(globalIndicesProvider);
            ref.invalidate(marketBreadthProvider);
            ref.invalidate(earningsCalendarProvider);
            ref.invalidate(sectorPerformanceProvider);
            ref.invalidate(marketSentimentProvider);
            ref.invalidate(highLowProvider);
            ref.invalidate(ipoDataProvider);
            ref.invalidate(healthStatusProvider);
          },
          color: AppColors.primary,
          backgroundColor: AppColors.surface1,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Consumer(
                builder: (context, ref, child) {
                  final healthAsync = ref.watch(healthStatusProvider);
                  final bool hasFailedPipelines = healthAsync.value?.values.any((p) => p['status'] == 'failed') ?? false;
                  
                  if (hasFailedPipelines) {
                    return StaleBanner.stale('Some data may be outdated due to pipeline failures.');
                  }
                  return const SizedBox.shrink();
                },
              ),
              const Padding(
                padding: AppSpacing.screenPadding,
                child: Column(
                  children: [
                    _SummaryHeader(),
                    SizedBox(height: AppSpacing.lg),
                    _CriticalTodaySection(),
                    SizedBox(height: AppSpacing.lg),
                    _UpcomingSection(),
                    SizedBox(height: AppSpacing.lg),
                    _MarketStatusStrip(),
                    SizedBox(height: AppSpacing.lg),
                    _DataHealthSection(),
                    SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryHeader extends ConsumerWidget {
  const _SummaryHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayEvents = ref.watch(criticalTodayProvider);

    return todayEvents.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (events) {
        final count = events.where((e) => e.importanceIndex == 0).length;
        if (count == 0) return const SizedBox.shrink();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Today:', style: AppTypography.metadata),
            Text('$count Critical Events', style: AppTypography.value.copyWith(color: AppColors.danger)),
          ],
        );
      },
    );
  }
}

class _CriticalTodaySection extends ConsumerWidget {
  const _CriticalTodaySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayEvents = ref.watch(criticalTodayProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'CRITICAL TODAY'),
        todayEvents.when(
          loading: () => const SkeletonLoader(itemCount: 2, itemHeight: 72),
          error: (_, __) => const SizedBox.shrink(),
          data: (events) {
            final critical = events.where((e) => e.importanceIndex == 0).toList();
            if (critical.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Text('No critical events today.', style: AppTypography.bodySecondary),
              );
            }
            return Column(
              children: critical.map((event) => EventCard(
                title: event.entity,
                subtitle: event.title,
                importance: ImportanceLevel.critical,
                source: event.eventType,
              )).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _UpcomingSection extends ConsumerWidget {
  const _UpcomingSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upcomingEvents = ref.watch(upcoming7DaysProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'UPCOMING'),
        upcomingEvents.when(
          loading: () => const SkeletonLoader(itemCount: 3, itemHeight: 72),
          error: (_, __) => const SizedBox.shrink(),
          data: (events) {
            final important = events.where((e) => e.importanceIndex <= 1).take(5).toList();
            if (important.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Text('No major upcoming events.', style: AppTypography.bodySecondary),
              );
            }
            return Column(
              children: important.map((event) => EventCard(
                title: event.entity,
                subtitle: event.title,
                date: event.date,
                importance: event.importanceIndex == 0 ? ImportanceLevel.critical : ImportanceLevel.high,
                source: event.eventType,
              )).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _MarketStatusStrip extends ConsumerWidget {
  const _MarketStatusStrip();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'MARKET STATUS'),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface1,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(color: AppColors.border),
          ),
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: const Column(
            children: [
              FearAndGreedGaugeWidget(),
              Divider(height: AppSpacing.md, color: AppColors.border),
              _CompactMarketBreadth(),
              Divider(height: AppSpacing.md, color: AppColors.border),
              _CompactFiiDii(),
              Divider(height: AppSpacing.md, color: AppColors.border),
              _CompactGlobalIndices(),
            ],
          ),
        ),
      ],
    );
  }
}

class _CompactMarketBreadth extends ConsumerWidget {
  const _CompactMarketBreadth();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(marketBreadthProvider);
    return FadeSwitcher(
      child: asyncData.when(
        loading: () => const SizedBox(height: 24, child: Center(child: LinearProgressIndicator())),
        error: (_, __) => const SizedBox.shrink(),
        data: (response) {
          if (response.data.isEmpty) return const SizedBox.shrink();
          final breadth = response.data.first;
          final advances = (breadth.up ?? breadth.advance ?? 0).toInt();
          final declines = (breadth.dn ?? breadth.decline ?? 0).toInt();
          
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Breadth', style: AppTypography.metadata),
              Row(
                children: [
                  Text('ADV $advances', style: AppTypography.metadata.copyWith(color: AppColors.success, fontWeight: FontWeight.bold)),
                  const SizedBox(width: AppSpacing.md),
                  Text('DEC $declines', style: AppTypography.metadata.copyWith(color: AppColors.danger, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CompactFiiDii extends ConsumerWidget {
  const _CompactFiiDii();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(fiiDiiDataProvider);
    return FadeSwitcher(
      child: asyncData.when(
        loading: () => const SizedBox(height: 24),
        error: (_, __) => const SizedBox.shrink(),
        data: (response) {
          if (response.data.isEmpty) return const SizedBox.shrink();
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Flows', style: AppTypography.metadata),
              Row(
                children: response.data.take(2).map((item) {
                  final isPositive = (item.netValue ?? 0) >= 0;
                  return Padding(
                    padding: const EdgeInsets.only(left: AppSpacing.md),
                    child: Text(
                      '${item.category} ${isPositive ? '+' : ''}${item.netValue?.toStringAsFixed(0)}Cr',
                      style: AppTypography.metadata.copyWith(
                        color: isPositive ? AppColors.success : AppColors.danger,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CompactGlobalIndices extends ConsumerWidget {
  const _CompactGlobalIndices();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(globalIndicesProvider);
    return FadeSwitcher(
      child: asyncData.when(
        loading: () => const SizedBox(height: 24),
        error: (_, __) => const SizedBox.shrink(),
        data: (response) {
          if (response.data.isEmpty) return const SizedBox.shrink();
          final nifty = response.data.firstWhere((e) => e.symbol == '^NSEI', orElse: () => response.data.first);
          final isPositive = (nifty.changePct ?? 0) >= 0;
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('NIFTY 50', style: AppTypography.metadata),
              Text(
                '${nifty.price?.toStringAsFixed(2) ?? '-'} (${isPositive ? '+' : ''}${nifty.changePct?.toStringAsFixed(2)}%)',
                style: AppTypography.metadata.copyWith(
                  color: isPositive ? AppColors.success : AppColors.danger,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DataHealthSection extends ConsumerWidget {
  const _DataHealthSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthData = ref.watch(healthStatusProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'DATA HEALTH'),
        healthData.when(
          loading: () => const SkeletonLoader(itemCount: 1, itemHeight: 40),
          error: (_, __) => const SizedBox.shrink(),
          data: (healthMap) {
            final allHealthy = healthMap.values.every((v) => v['status'] == 'healthy');
            final color = allHealthy ? AppColors.success : AppColors.warning;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.surface1,
                borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('System Status', style: AppTypography.metadata),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        allHealthy ? 'ALL SYSTEMS OPERATIONAL' : 'DEGRADED PERFORMANCE',
                        style: AppTypography.metadata.copyWith(color: color, fontWeight: FontWeight.bold, fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
