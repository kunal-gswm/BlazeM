import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
    return GestureDetector(
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
            final fii = response.data.firstWhere((e) => e.category == 'FII', orElse: () => response.data.first);
            final isPositive = (fii.netValue ?? 0) >= 0;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('FII Net Flow', style: AppTypography.metadata),
                Text(
                  '${isPositive ? '+' : ''}${fii.netValue?.toStringAsFixed(0)} Cr',
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
                  topSector.symbol ?? 'Unknown',
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
