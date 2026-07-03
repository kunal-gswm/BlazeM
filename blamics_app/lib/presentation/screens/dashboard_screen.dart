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
import '../widgets/importance_indicator.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../widgets/bento_cards.dart';

void _showEventDetails(BuildContext context, WidgetRef ref, dynamic event, ImportanceLevel importance) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) {
      return Container(
        margin: const EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          bottom: AppSpacing.xl,
        ),
        padding: AppSpacing.screenPadding,
        decoration: BoxDecoration(
          color: AppColors.surface1,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                ImportanceIndicator(level: importance),
                const SizedBox(width: AppSpacing.sm),
                Text((event.eventType as String).toUpperCase(), style: AppTypography.metadata),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(event.entity as String, style: AppTypography.screenTitle.copyWith(fontSize: 20)),
            const SizedBox(height: AppSpacing.xs),
            Text(event.title as String, style: AppTypography.bodyMedium),
            const SizedBox(height: AppSpacing.lg),
            Text('Date: ${event.date}', style: AppTypography.value.copyWith(fontSize: 14)),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context); // Close bottom sheet
                  ref.read(navigationProvider.notifier).state = 1; // Go to Timeline tab
                },
                child: const Text('View in Timeline'),
              ),
            ),
          ],
        ),
      );
    },
  );
}

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
            ref.invalidate(commoditiesProvider);
            ref.invalidate(currencyProvider);
            ref.invalidate(volumeShockerProvider);
            ref.invalidate(circuitBreakersProvider);
            ref.invalidate(healthStatusProvider);
          },
          color: AppColors.primary,
          backgroundColor: AppColors.surface1,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
            children: [
              Consumer(
                builder: (context, ref, child) {
                  final healthAsync = ref.watch(healthStatusProvider);
                  final bool hasFailedPipelines = healthAsync.value?.values.any((p) => p['status'] == 'failed') ?? false;
                  
                  if (hasFailedPipelines) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: StaleBanner.stale('Some data may be outdated due to pipeline failures.'),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              const _SummaryHeader(),
              const SizedBox(height: AppSpacing.md),
              
              // HERO SECTION
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surface1,
                  borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                  border: Border.all(color: AppColors.border),
                ),
                child: const FearAndGreedGaugeWidget(),
              ).animate().fade(duration: 500.ms).slideY(begin: 0.1),
              
              const SizedBox(height: AppSpacing.lg),
              
              // BENTO BOX GRID
              const SectionHeader(title: 'MARKET STATUS & INTELLIGENCE'),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: AppSpacing.sm,
                mainAxisSpacing: AppSpacing.sm,
                childAspectRatio: 1.1, // Adjust slightly to make them look packed
                children: [
                  const BentoFiiDii().animate().fade(delay: 100.ms).slideY(begin: 0.1),
                  const BentoBreadth().animate().fade(delay: 150.ms).slideY(begin: 0.1),
                  const BentoGlobal().animate().fade(delay: 200.ms).slideY(begin: 0.1),
                  const BentoSector().animate().fade(delay: 250.ms).slideY(begin: 0.1),
                  const BentoCommodities().animate().fade(delay: 300.ms).slideY(begin: 0.1),
                  const BentoCurrency().animate().fade(delay: 350.ms).slideY(begin: 0.1),
                  const BentoVolumeShocker().animate().fade(delay: 400.ms).slideY(begin: 0.1),
                  const BentoCircuitBreakers().animate().fade(delay: 450.ms).slideY(begin: 0.1),
                ],
              ),
              
              const SizedBox(height: AppSpacing.xl),
              const _CriticalTodaySection(),
              const SizedBox(height: AppSpacing.xl),
              const _UpcomingSection(),
              const SizedBox(height: AppSpacing.xl),
              const _DataHealthSection(),
              const SizedBox(height: AppSpacing.xl),
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
              children: critical.asMap().entries.map((entry) {
                final index = entry.key;
                final event = entry.value;
                return EventCard(
                  title: event.entity,
                  subtitle: event.title,
                  importance: ImportanceLevel.critical,
                  source: event.eventType,
                  onTap: () => _showEventDetails(context, ref, event, ImportanceLevel.critical),
                ).animate(delay: (index * 50).ms).fade(duration: 400.ms).slideY(begin: 0.1, duration: 400.ms);
              }).toList(),
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
              children: important.asMap().entries.map((entry) {
                final index = entry.key;
                final event = entry.value;
                final importance = event.importanceIndex == 0 ? ImportanceLevel.critical : ImportanceLevel.high;
                return EventCard(
                  title: event.entity,
                  subtitle: event.title,
                  date: event.date,
                  importance: importance,
                  source: event.eventType,
                  onTap: () => _showEventDetails(context, ref, event, importance),
                ).animate(delay: (index * 50).ms).fade(duration: 400.ms).slideY(begin: 0.1, duration: 400.ms);
              }).toList(),
            );
          },
        ),
      ],
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
            return GestureDetector(
              onTap: () => ref.read(navigationProvider.notifier).state = 4, // Settings & Info tab
              behavior: HitTestBehavior.opaque,
              child: Container(
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
                        const SizedBox(width: AppSpacing.sm),
                        const Icon(Icons.chevron_right, size: 16, color: AppColors.textSecondary),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
