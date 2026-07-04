import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../data/repositories/providers.dart';
import 'fade_switcher.dart';

class BentoCard extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback onTap;

  const BentoCard({
    super.key,
    required this.title,
    required this.child,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface1,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: AppTypography.metadata),
                const Icon(Icons.arrow_outward, size: 14, color: AppColors.textSecondary),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Expanded(child: child),
          ],
        ),
      ),
    ),
    );
  }
}

class BentoFiiDii extends ConsumerWidget {
  const BentoFiiDii({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(fiiDiiDataProvider);
    return BentoCard(
      title: 'FII / DII',
      onTap: () => ref.read(navigationProvider.notifier).state = 8,
      child: FadeSwitcher(
        child: asyncData.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Center(child: Icon(Icons.error, color: AppColors.danger)),
          data: (response) {
            if (response.data.isEmpty) return const SizedBox.shrink();
            final fii = response.data.firstWhere((e) => e.category.toUpperCase().contains('FII'), orElse: () => response.data.first);
            final isPositive = (fii.netValue ?? 0) >= 0;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('FII Net Flow', style: AppTypography.metadata),
                Text(
                  '${isPositive ? '+' : ''}${(fii.netValue ?? 0).toStringAsFixed(0)} Cr',
                  style: AppTypography.screenTitle.copyWith(
                    color: isPositive ? AppColors.success : AppColors.danger,
                    fontSize: 22,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class BentoBreadth extends ConsumerWidget {
  const BentoBreadth({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(marketBreadthProvider);
    return BentoCard(
      title: 'Breadth',
      onTap: () => ref.read(navigationProvider.notifier).state = 6,
      child: FadeSwitcher(
        child: asyncData.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Center(child: Icon(Icons.error, color: AppColors.danger)),
          data: (response) {
            if (response.data.isEmpty) return const SizedBox.shrink();
            final breadth = response.data.first;
            final advances = (breadth.up ?? breadth.advance ?? 0).toInt();
            final declines = (breadth.dn ?? breadth.decline ?? 0).toInt();
            final total = advances + declines;
            final advPct = total > 0 ? (advances / total) : 0.5;

            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('$advances', style: AppTypography.bodyMedium.copyWith(color: AppColors.success, fontWeight: FontWeight.bold)),
                    Text('$declines', style: AppTypography.bodyMedium.copyWith(color: AppColors.danger, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: advPct,
                    backgroundColor: AppColors.danger,
                    color: AppColors.success,
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('ADV', style: AppTypography.metadata.copyWith(fontSize: 10)),
                    Text('DEC', style: AppTypography.metadata.copyWith(fontSize: 10)),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class BentoSector extends ConsumerWidget {
  const BentoSector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(sectorPerformanceProvider);
    return BentoCard(
      title: 'Top Sector',
      onTap: () => ref.read(navigationProvider.notifier).state = 5,
      child: FadeSwitcher(
        child: asyncData.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Center(child: Icon(Icons.error, color: AppColors.danger)),
          data: (response) {
            if (response.data.isEmpty) return const SizedBox.shrink();
            final sectors = List.of(response.data);
            sectors.sort((a, b) => (b.percentChange ?? 0).compareTo(a.percentChange ?? 0));
            final topSector = sectors.first;
            final isPositive = (topSector.percentChange ?? 0) >= 0;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  topSector.symbol,
                  style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${isPositive ? '+' : ''}${topSector.percentChange?.toStringAsFixed(2)}%',
                  style: AppTypography.screenTitle.copyWith(
                    color: isPositive ? AppColors.success : AppColors.danger,
                    fontSize: 20,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class BentoGlobal extends ConsumerWidget {
  const BentoGlobal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(globalIndicesProvider);
    return BentoCard(
      title: 'NIFTY 50',
      onTap: () => {}, // Maybe Global Indices screen in future
      child: FadeSwitcher(
        child: asyncData.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Center(child: Icon(Icons.error, color: AppColors.danger)),
          data: (response) {
            if (response.data.isEmpty) return const SizedBox.shrink();
            final nifty = response.data.firstWhere((e) => e.symbol == '^NSEI', orElse: () => response.data.first);
            final isPositive = (nifty.changePct ?? 0) >= 0;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  nifty.price?.toStringAsFixed(2) ?? '-',
                  style: AppTypography.screenTitle.copyWith(fontSize: 20),
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: (isPositive ? AppColors.success : AppColors.danger).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${isPositive ? '+' : ''}${nifty.changePct?.toStringAsFixed(2)}%',
                    style: AppTypography.metadata.copyWith(
                      color: isPositive ? AppColors.success : AppColors.danger,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class BentoCommodities extends ConsumerWidget {
  const BentoCommodities({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(commoditiesProvider);
    return BentoCard(
      title: 'Commodities',
      onTap: () => ref.read(navigationProvider.notifier).state = 9,
      child: FadeSwitcher(
        child: asyncData.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Center(child: Icon(Icons.error, color: AppColors.danger)),
          data: (response) {
            if (response.data.isEmpty) return const SizedBox.shrink();
            final gold = response.data.firstWhere((e) => e.symbol == 'GC=F', orElse: () => response.data.first);
            final isPositive = (gold.changePct ?? 0) >= 0;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('Gold (Gold/Oz)', style: AppTypography.metadata),
                Text(
                  '\$${gold.price?.toStringAsFixed(1) ?? gold.price}',
                  style: AppTypography.screenTitle.copyWith(fontSize: 20),
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: (isPositive ? AppColors.success : AppColors.danger).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${gold.changePct != null ? (isPositive ? '+' : '') : ''}${gold.changePct?.toStringAsFixed(2) ?? '-'}%',
                    style: AppTypography.metadata.copyWith(
                      color: isPositive ? AppColors.success : AppColors.danger,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class BentoCurrency extends ConsumerWidget {
  const BentoCurrency({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(currencyProvider);
    return BentoCard(
      title: 'USD / INR',
      onTap: () => ref.read(navigationProvider.notifier).state = 10,
      child: FadeSwitcher(
        child: asyncData.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Center(child: Icon(Icons.error, color: AppColors.danger)),
          data: (response) {
            if (response.data.isEmpty) return const SizedBox.shrink();
            final usdinr = response.data.firstWhere((e) => e.symbol == 'INR=X', orElse: () => response.data.first);
            final isPositive = (usdinr.changePct ?? 0) >= 0;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('Exchange Rate', style: AppTypography.metadata),
                Text(
                  '₹${usdinr.rate?.toStringAsFixed(2) ?? usdinr.rate}',
                  style: AppTypography.screenTitle.copyWith(fontSize: 20),
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: (isPositive ? AppColors.danger : AppColors.success).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${usdinr.changePct != null ? (isPositive ? '+' : '') : ''}${usdinr.changePct?.toStringAsFixed(2) ?? '-'}%',
                    style: AppTypography.metadata.copyWith(
                      color: isPositive ? AppColors.danger : AppColors.success,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class BentoVolumeShocker extends ConsumerWidget {
  const BentoVolumeShocker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(volumeShockerProvider);
    return BentoCard(
      title: 'Vol Shocker ⚡',
      onTap: () => ref.read(navigationProvider.notifier).state = 11,
      child: FadeSwitcher(
        child: asyncData.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Center(child: Icon(Icons.error, color: AppColors.danger)),
          data: (response) {
            if (response.data.isEmpty) return const SizedBox.shrink();
            final top = response.data.first;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  top.symbol,
                  style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '₹${top.lastPrice}',
                  style: AppTypography.screenTitle.copyWith(fontSize: 20),
                ),
                const SizedBox(height: 2),
                Text(
                  '1W Vol: +${top.volChange1WkPct?.toStringAsFixed(0) ?? '-'}%',
                  style: AppTypography.metadata.copyWith(color: Colors.amber, fontWeight: FontWeight.bold),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class BentoCircuitBreakers extends ConsumerWidget {
  const BentoCircuitBreakers({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(circuitBreakersProvider);
    return BentoCard(
      title: '10%+ Circuits 🚀',
      onTap: () => ref.read(navigationProvider.notifier).state = 12,
      child: FadeSwitcher(
        child: asyncData.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Center(child: Icon(Icons.error, color: AppColors.danger)),
          data: (response) {
            if (response.data.isEmpty) return const SizedBox.shrink();
            final model = response.data.first;
            final count = model.upperCircuit.length + model.lowerCircuit.length;
            final topSymbol = model.upperCircuit.isNotEmpty ? model.upperCircuit.first.symbol : (model.lowerCircuit.isNotEmpty ? model.lowerCircuit.first.symbol : 'None');

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('$count Active Stocks', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.success)),
                Text(
                  topSymbol,
                  style: AppTypography.screenTitle.copyWith(fontSize: 20),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Intraday Extreme',
                  style: AppTypography.metadata,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
