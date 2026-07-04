import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_enums.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../data/repositories/providers.dart';
import '../widgets/event_card.dart';
import '../widgets/section_header.dart';
import '../widgets/skeleton_loader.dart';
import '../widgets/stale_banner.dart';
import '../widgets/importance_indicator.dart';
import 'stock_detail_screen.dart';

void _showEventDetails(BuildContext context, WidgetRef ref, dynamic event, ImportanceLevel importance) {
  if (event == null) return;
  
  final String eventType = (event.eventType?.toString() ?? 'EVENT').toUpperCase();
  final String entity = event.entity?.toString() ?? 'Unknown Entity';
  final String title = event.title?.toString() ?? 'No Details Available';
  final String dateStr = event.date?.toString() ?? 'Date TBD';

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
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
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.8),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
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
                    Expanded(
                      child: Text(
                        eventType, 
                        style: AppTypography.metadata.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(entity, style: AppTypography.screenTitle.copyWith(fontSize: 20, color: Colors.white)),
                const SizedBox(height: AppSpacing.xs),
                Text(title, style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: AppSpacing.lg),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surface2,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      Text('Date: $dateStr', style: AppTypography.value.copyWith(fontSize: 13, color: Colors.white)),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: AppColors.border),
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context); // Close bottom sheet
                          Navigator.push(context, MaterialPageRoute(builder: (_) => StockDetailScreen(symbol: entity)));
                        },
                        child: const Text('View Fundamentals'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
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
              ],
            ),
          ),
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
              
              // SECTION 1: TOP HERO - UNIFIED GLASS PULSE BANNER
              const _NeoGlassPulseBanner(),
              const SizedBox(height: AppSpacing.xl),
              
              // SECTION 2: LIVE MULTIPLIERS & BENCHMARK RATES CAROUSEL
              const SectionHeader(title: 'LIVE MULTIPLIERS & BENCHMARKS'),
              const _NeoMultipliersCarousel(),
              const SizedBox(height: AppSpacing.xl),
              
              // SECTION 3: MOMENTUM SCANNERS (VOLUME SHOCKERS & CIRCUIT BREAKERS)
              const SectionHeader(title: 'MOMENTUM SCANNERS'),
              const _NeoMomentumScanners(),
              const SizedBox(height: AppSpacing.xl),
              
              // SECTION 4: BOTTOM FEED - CRITICAL TODAY & ACTION RADAR
              const _NeoActionRadar(),
              const SizedBox(height: AppSpacing.xl),
              
              // SYSTEM DATA HEALTH
              const _DataHealthSection(),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

// SECTION 1 IMPLEMENTATION: UNIFIED GLASS PULSE BANNER
class _NeoGlassPulseBanner extends ConsumerStatefulWidget {
  const _NeoGlassPulseBanner();

  @override
  ConsumerState<_NeoGlassPulseBanner> createState() => _NeoGlassPulseBannerState();
}

class _NeoGlassPulseBannerState extends ConsumerState<_NeoGlassPulseBanner> {
  bool _showFiiDetails = false;
  bool _showBreadthDetails = false;

  @override
  Widget build(BuildContext context) {
    final indicesAsync = ref.watch(globalIndicesProvider);
    final sentimentAsync = ref.watch(marketSentimentProvider);
    final fiiAsync = ref.watch(fiiDiiDataProvider);
    final breadthAsync = ref.watch(marketBreadthProvider);

    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface1,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    Text('MARKET PULSE', style: AppTypography.metadata.copyWith(letterSpacing: 1.5, color: AppColors.textSecondary)),
                  ],
                ),
                sentimentAsync.when(
                  loading: () => Text('SYNCING...', style: AppTypography.metadata),
                  error: (_, __) => Text('NEUTRAL', style: AppTypography.metadata),
                  data: (res) {
                    final status = res.data.isNotEmpty ? res.data.first.label : 'Neutral';
                    final color = status.toLowerCase().contains('greed') 
                        ? AppColors.success 
                        : (status.toLowerCase().contains('fear') ? AppColors.danger : AppColors.warning);
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: color.withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: AppTypography.metadata.copyWith(color: color, fontWeight: FontWeight.bold, fontSize: 10),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            indicesAsync.when(
              loading: () => const SkeletonLoader(itemCount: 1, itemHeight: 48),
              error: (_, __) => Text('NIFTY 50 — DATA UNAVAILABLE', style: AppTypography.screenTitle),
              data: (res) {
                if (res.data.isEmpty) return const SizedBox.shrink();
                final nifty = res.data.firstWhere((e) => e.symbol == '^NSEI', orElse: () => res.data.first);
                final isPositive = (nifty.changePct ?? 0) >= 0;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('NIFTY 50', style: AppTypography.bodySecondary.copyWith(fontSize: 12)),
                        Text(
                          nifty.price?.toStringAsFixed(2) ?? '—',
                          style: AppTypography.screenTitle.copyWith(fontSize: 28, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: (isPositive ? AppColors.success : AppColors.danger).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${isPositive ? '+' : ''}${nifty.changePct?.toStringAsFixed(2)}%',
                        style: AppTypography.value.copyWith(
                          color: isPositive ? AppColors.success : AppColors.danger,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            const Divider(color: AppColors.border, height: 1),
            const SizedBox(height: AppSpacing.md),
            
            // INTERACTIVE EXPANDABLE PILL BADGES
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _showFiiDetails = !_showFiiDetails),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: _showFiiDetails ? AppColors.primary.withValues(alpha: 0.1) : AppColors.background,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: _showFiiDetails ? AppColors.primary : AppColors.border),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('FII FLOW', style: AppTypography.metadata.copyWith(fontSize: 11)),
                          fiiAsync.when(
                            loading: () => Text('...', style: AppTypography.metadata),
                            error: (_, __) => Text('-', style: AppTypography.metadata),
                            data: (res) {
                              if (res.data.isEmpty) return Text('-', style: AppTypography.metadata);
                              final fii = res.data.firstWhere((e) => e.category.toUpperCase().contains('FII'), orElse: () => res.data.first);
                              final isPos = (fii.netValue ?? 0) >= 0;
                              return Text(
                                '${isPos ? '+' : ''}${(fii.netValue ?? 0).toStringAsFixed(0)} Cr',
                                style: AppTypography.metadata.copyWith(
                                  color: isPos ? AppColors.success : AppColors.danger,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _showBreadthDetails = !_showBreadthDetails),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: _showBreadthDetails ? AppColors.primary.withValues(alpha: 0.1) : AppColors.background,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: _showBreadthDetails ? AppColors.primary : AppColors.border),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('BREADTH', style: AppTypography.metadata.copyWith(fontSize: 11)),
                          breadthAsync.when(
                            loading: () => Text('...', style: AppTypography.metadata),
                            error: (_, __) => Text('-', style: AppTypography.metadata),
                            data: (res) {
                              if (res.data.isEmpty) return Text('-', style: AppTypography.metadata);
                              final breadth = res.data.first;
                              final adv = (breadth.up ?? breadth.advance ?? 0).toInt();
                              final dec = (breadth.dn ?? breadth.decline ?? 0).toInt();
                              return Text(
                                '$adv : $dec',
                                style: AppTypography.metadata.copyWith(
                                  color: adv >= dec ? AppColors.success : AppColors.danger,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            // EXPANDED DETAILS DRAWER
            if (_showFiiDetails)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: fiiAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (res) {
                      if (res.data.isEmpty) return const SizedBox.shrink();
                      return Column(
                        children: res.data.take(2).map((e) {
                          final isPos = (e.netValue ?? 0) >= 0;
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(e.category, style: AppTypography.metadata),
                              Text(
                                '${isPos ? '+' : ''}${(e.netValue ?? 0).toStringAsFixed(2)} Cr',
                                style: AppTypography.metadata.copyWith(
                                  color: isPos ? AppColors.success : AppColors.danger,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
              ),
            if (_showBreadthDetails)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: breadthAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (res) {
                      if (res.data.isEmpty) return const SizedBox.shrink();
                      final breadth = res.data.first;
                      final adv = (breadth.up ?? breadth.advance ?? 0).toInt();
                      final dec = (breadth.dn ?? breadth.decline ?? 0).toInt();
                      final total = adv + dec;
                      final pct = total > 0 ? (adv / total) : 0.5;
                      return Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Advances: $adv', style: AppTypography.metadata.copyWith(color: AppColors.success)),
                              Text('Decliners: $dec', style: AppTypography.metadata.copyWith(color: AppColors.danger)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: pct,
                              backgroundColor: AppColors.danger,
                              color: AppColors.success,
                              minHeight: 4,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// SECTION 2 IMPLEMENTATION: LIVE MULTIPLIERS & BENCHMARK RATES CAROUSEL
class _NeoMultipliersCarousel extends ConsumerStatefulWidget {
  const _NeoMultipliersCarousel();

  @override
  ConsumerState<_NeoMultipliersCarousel> createState() => _NeoMultipliersCarouselState();
}

class _NeoMultipliersCarouselState extends ConsumerState<_NeoMultipliersCarousel> {
  int _selectedTab = 0; // 0: All, 1: Commodities, 2: Currencies, 3: IPOs, 4: Sectors

  final List<String> _tabs = ['All', 'Commodities 🛢️', 'Currencies 💵', 'IPO Multipliers 🚀', 'Sectors 📊'];

  @override
  Widget build(BuildContext context) {
    final commoditiesAsync = ref.watch(commoditiesProvider);
    final currencyAsync = ref.watch(currencyProvider);
    final ipoAsync = ref.watch(ipoDataProvider);
    final sectorAsync = ref.watch(sectorPerformanceProvider);

    List<Widget> cards = [];

    // COMMODITIES
    if (_selectedTab == 0 || _selectedTab == 1) {
      commoditiesAsync.whenData((res) {
        for (var c in res.data.take(_selectedTab == 1 ? 6 : 2)) {
          final isPos = (c.changePct ?? 0) >= 0;
          cards.add(_buildMiniCard(
            title: c.name,
            subtitle: '\$${c.price?.toStringAsFixed(2) ?? '-'}',
            badgeText: '${isPos ? '+' : ''}${c.changePct?.toStringAsFixed(2)}%',
            isPositive: isPos,
            onTap: () => ref.read(navigationProvider.notifier).state = 9,
          ));
        }
      });
    }

    // CURRENCIES
    if (_selectedTab == 0 || _selectedTab == 2) {
      currencyAsync.whenData((res) {
        for (var c in res.data.take(_selectedTab == 2 ? 6 : 2)) {
          final isPos = (c.changePct ?? 0) >= 0;
          cards.add(_buildMiniCard(
            title: c.symbol,
            subtitle: '₹${c.rate?.toStringAsFixed(2) ?? '-'}',
            badgeText: '${isPos ? '+' : ''}${c.changePct?.toStringAsFixed(2)}%',
            isPositive: !isPos, // Stronger INR is lower exchange rate
            onTap: () => ref.read(navigationProvider.notifier).state = 10,
          ));
        }
      });
    }

    // IPO MULTIPLIERS
    if (_selectedTab == 0 || _selectedTab == 3) {
      ipoAsync.whenData((res) {
        final openIpos = res.data.where((i) => i.subscriptionTotal != null && i.subscriptionTotal!.isNotEmpty).take(_selectedTab == 3 ? 6 : 2);
        for (var ipo in openIpos) {
          cards.add(_buildMiniCard(
            title: ipo.issueName,
            subtitle: 'Total: ${ipo.subscriptionTotal}x',
            badgeText: 'QIB: ${ipo.subscriptionQib ?? '-'}x',
            isPositive: true,
            onTap: () => ref.read(navigationProvider.notifier).state = 3,
          ));
        }
      });
    }

    // SECTORS
    if (_selectedTab == 0 || _selectedTab == 4) {
      sectorAsync.whenData((res) {
        final sectors = List.of(res.data);
        sectors.sort((a, b) => (b.percentChange ?? 0).compareTo(a.percentChange ?? 0));
        for (var s in sectors.take(_selectedTab == 4 ? 6 : 2)) {
          final isPos = (s.percentChange ?? 0) >= 0;
          cards.add(_buildMiniCard(
            title: s.symbol,
            subtitle: '${isPos ? '+' : ''}${s.percentChange?.toStringAsFixed(2)}%',
            badgeText: 'TOP PERFORMER',
            isPositive: isPos,
            onTap: () => ref.read(navigationProvider.notifier).state = 5,
          ));
        }
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _tabs.asMap().entries.map((entry) {
              final idx = entry.key;
              final label = entry.value;
              final isSelected = _selectedTab == idx;
              return Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedTab = idx),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.surface1,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
                    ),
                    child: Text(
                      label,
                      style: AppTypography.metadata.copyWith(
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 110,
          child: cards.isEmpty
              ? const SkeletonLoader(itemCount: 2, itemHeight: 110)
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: cards.length,
                  separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
                  itemBuilder: (context, index) => cards[index],
                ),
        ),
      ],
    );
  }

  Widget _buildMiniCard({
    required String title,
    required String subtitle,
    required String badgeText,
    required bool isPositive,
    required VoidCallback onTap,
  }) {
    return RepaintBoundary(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 160,
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.surface1,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                subtitle,
                style: AppTypography.screenTitle.copyWith(fontSize: 18),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: (isPositive ? AppColors.success : AppColors.danger).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  badgeText,
                  style: AppTypography.metadata.copyWith(
                    color: isPositive ? AppColors.success : AppColors.danger,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// SECTION 3 IMPLEMENTATION: MOMENTUM SCANNERS (VOLUME SHOCKERS & CIRCUIT BREAKERS)
class _NeoMomentumScanners extends ConsumerStatefulWidget {
  const _NeoMomentumScanners();

  @override
  ConsumerState<_NeoMomentumScanners> createState() => _NeoMomentumScannersState();
}

class _NeoMomentumScannersState extends ConsumerState<_NeoMomentumScanners> {
  bool _volExpanded = false;
  bool _circuitExpanded = false;

  @override
  Widget build(BuildContext context) {
    final volAsync = ref.watch(volumeShockerProvider);
    final circuitAsync = ref.watch(circuitBreakersProvider);

    return Column(
      children: [
        // ACCORDION 1: VOLUME SHOCKERS
        RepaintBoundary(
          child: Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.surface1,
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              border: Border.all(color: _volExpanded ? Colors.amber : AppColors.border),
            ),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => setState(() => _volExpanded = !_volExpanded),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.bolt, color: Colors.amber, size: 20),
                            const SizedBox(width: 8),
                            Text('VOLUME SHOCKERS ⚡', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Row(
                          children: [
                            volAsync.when(
                              loading: () => const SizedBox.shrink(),
                              error: (_, __) => const SizedBox.shrink(),
                              data: (res) {
                                if (res.data.isEmpty) return const SizedBox.shrink();
                                final top = res.data.first;
                                return Text(
                                  '#1 ${top.symbol} (+${top.volChange1WkPct?.toStringAsFixed(0) ?? '-'}%)',
                                  style: AppTypography.metadata.copyWith(color: Colors.amber, fontWeight: FontWeight.bold),
                                );
                              },
                            ),
                            const SizedBox(width: 8),
                            Icon(_volExpanded ? Icons.expand_less : Icons.expand_more, color: AppColors.textSecondary),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (_volExpanded)
                  volAsync.when(
                    loading: () => const Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()),
                    error: (_, __) => const Padding(padding: EdgeInsets.all(16), child: Text('Error loading volume shockers')),
                    data: (res) {
                      if (res.data.isEmpty) return Padding(padding: const EdgeInsets.all(16), child: Text('No volume shockers found.', style: AppTypography.bodySecondary));
                      return Column(
                        children: res.data.take(5).map((item) {
                          return ListTile(
                            dense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                            title: Text(item.symbol, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                            subtitle: Text('₹${item.lastPrice} | Val: ₹${item.turnoverCr?.toStringAsFixed(1) ?? '-'} Cr', style: AppTypography.metadata),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: Colors.amber.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
                              child: Text('+${item.volChange1WkPct?.toStringAsFixed(0) ?? '-'}% Vol', style: AppTypography.metadata.copyWith(color: Colors.amber, fontWeight: FontWeight.bold)),
                            ),
                            onTap: () => ref.read(navigationProvider.notifier).state = 11,
                          );
                        }).toList(),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),

        // ACCORDION 2: 10%+ CIRCUIT BREAKERS
        RepaintBoundary(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface1,
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              border: Border.all(color: _circuitExpanded ? AppColors.success : AppColors.border),
            ),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => setState(() => _circuitExpanded = !_circuitExpanded),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.rocket_launch, color: AppColors.success, size: 18),
                            const SizedBox(width: 8),
                            Text('10%+ CIRCUITS 🚀', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Row(
                          children: [
                            circuitAsync.when(
                              loading: () => const SizedBox.shrink(),
                              error: (_, __) => const SizedBox.shrink(),
                              data: (res) {
                                if (res.data.isEmpty) return const SizedBox.shrink();
                                final model = res.data.first;
                                final total = model.upperCircuit.length + model.lowerCircuit.length;
                                return Text(
                                  '$total Active Stocks',
                                  style: AppTypography.metadata.copyWith(color: AppColors.success, fontWeight: FontWeight.bold),
                                );
                              },
                            ),
                            const SizedBox(width: 8),
                            Icon(_circuitExpanded ? Icons.expand_less : Icons.expand_more, color: AppColors.textSecondary),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (_circuitExpanded)
                  circuitAsync.when(
                    loading: () => const Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()),
                    error: (_, __) => const Padding(padding: EdgeInsets.all(16), child: Text('Error loading circuit breakers')),
                    data: (res) {
                      if (res.data.isEmpty) return Padding(padding: const EdgeInsets.all(16), child: Text('No circuit breakers active.', style: AppTypography.bodySecondary));
                      final model = res.data.first;
                      final items = [...model.upperCircuit.take(3), ...model.lowerCircuit.take(2)];
                      if (items.isEmpty) return Padding(padding: const EdgeInsets.all(16), child: Text('No circuit breakers active today.', style: AppTypography.bodySecondary));
                      return Column(
                        children: items.map((item) {
                          final isUpper = (item.changePct ?? 0) >= 0;
                          return ListTile(
                            dense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                            title: Text(item.symbol, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                            subtitle: Text('₹${item.lastPrice ?? '-'}', style: AppTypography.metadata),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: (isUpper ? AppColors.success : AppColors.danger).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${isUpper ? '+' : ''}${item.changePct?.toStringAsFixed(2) ?? '-'}%',
                                style: AppTypography.metadata.copyWith(
                                  color: isUpper ? AppColors.success : AppColors.danger,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            onTap: () => ref.read(navigationProvider.notifier).state = 12,
                          );
                        }).toList(),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// SECTION 4 IMPLEMENTATION: BOTTOM FEED (CRITICAL TODAY & ACTION RADAR)
class _NeoActionRadar extends ConsumerStatefulWidget {
  const _NeoActionRadar();

  @override
  ConsumerState<_NeoActionRadar> createState() => _NeoActionRadarState();
}

class _NeoActionRadarState extends ConsumerState<_NeoActionRadar> {
  bool _showUpcoming = false;

  @override
  Widget build(BuildContext context) {
    final todayAsync = ref.watch(criticalTodayProvider);
    final upcomingAsync = ref.watch(upcoming7DaysProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'ACTION RADAR & TIMELINE'),
        todayAsync.when(
          loading: () => const SkeletonLoader(itemCount: 2, itemHeight: 72),
          error: (_, __) => const SizedBox.shrink(),
          data: (events) {
            final critical = events.where((e) => e.importanceIndex == 0).toList();
            if (critical.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Text('No critical events requiring immediate action today.', style: AppTypography.bodySecondary),
              );
            }
            return Column(
              children: critical.map((event) {
                return RepaintBoundary(
                  child: EventCard(
                    title: event.entity,
                    subtitle: event.title,
                    importance: ImportanceLevel.critical,
                    source: event.eventType,
                    onTap: () => _showEventDetails(context, ref, event, ImportanceLevel.critical),
                  ),
                );
              }).toList(),
            );
          },
        ),
        const SizedBox(height: AppSpacing.md),
        GestureDetector(
          onTap: () => setState(() => _showUpcoming = !_showUpcoming),
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_month_outlined, size: 18, color: AppColors.textSecondary),
                    const SizedBox(width: 8),
                    Text('UPCOMING 7 DAYS DRAWER', style: AppTypography.metadata.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
                Icon(_showUpcoming ? Icons.expand_less : Icons.expand_more, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
        if (_showUpcoming)
          upcomingAsync.when(
            loading: () => const Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()),
            error: (_, __) => const SizedBox.shrink(),
            data: (events) {
              final important = events.where((e) => e.importanceIndex <= 1).take(5).toList();
              if (important.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('No major upcoming events.', style: AppTypography.bodySecondary),
                );
              }
              return Column(
                children: important.map((event) {
                  final imp = event.importanceIndex == 0 ? ImportanceLevel.critical : ImportanceLevel.high;
                  return RepaintBoundary(
                    child: EventCard(
                      title: event.entity,
                      subtitle: event.title,
                      date: event.date,
                      importance: imp,
                      source: event.eventType,
                      onTap: () => _showEventDetails(context, ref, event, imp),
                    ),
                  );
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
        const SectionHeader(title: 'SYSTEM TELEMETRY'),
        healthData.when(
          loading: () => const SkeletonLoader(itemCount: 1, itemHeight: 40),
          error: (_, __) => const SizedBox.shrink(),
          data: (healthMap) {
            final allHealthy = healthMap.values.every((v) => v['status'] == 'healthy');
            final color = allHealthy ? AppColors.success : AppColors.warning;
            return RepaintBoundary(
              child: GestureDetector(
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
                      Text('Live Pipeline Status', style: AppTypography.metadata),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            allHealthy ? 'ALL 13 SYSTEMS OPERATIONAL' : 'DEGRADED PERFORMANCE',
                            style: AppTypography.metadata.copyWith(color: color, fontWeight: FontWeight.bold, fontSize: 10),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          const Icon(Icons.chevron_right, size: 16, color: AppColors.textSecondary),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
