import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../data/repositories/providers.dart';
import 'skeleton_loader.dart';

class SectorHeatmapWidget extends ConsumerWidget {
  const SectorHeatmapWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(sectorPerformanceProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sector Performance', style: AppTypography.sectionTitle),
        const SizedBox(height: AppSpacing.sm),
        asyncData.when(
          loading: () => const SkeletonLoader(itemCount: 1, itemHeight: 100),
          error: (err, stack) => const SizedBox.shrink(),
          data: (response) {
            final sectors = response.data;
            if (sectors.isEmpty) return const SizedBox.shrink();
            
            return SizedBox(
              height: 100,
              child: ListView.separated(
                padding: EdgeInsets.zero,
                scrollDirection: Axis.horizontal,
                itemCount: sectors.length,
                separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final sector = sectors[index];
                  final isPositive = (sector.percentChange ?? 0) >= 0;
                  
                  final intensity = ((sector.percentChange ?? 0).abs() / 3.0).clamp(0.1, 1.0);
                  
                  final color = isPositive 
                      ? AppColors.success.withOpacity(intensity) 
                      : AppColors.danger.withOpacity(intensity);
                      
                  final textColor = isPositive ? AppColors.success : AppColors.danger;

                  return Container(
                    width: 140,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                      border: Border.all(color: color.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          sector.symbol.replaceAll('NIFTY ', ''),
                          style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          '${isPositive ? '+' : ''}${sector.percentChange?.toStringAsFixed(2)}%',
                          style: AppTypography.value.copyWith(
                            color: textColor,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${sector.lastPrice?.toStringAsFixed(1)}',
                          style: AppTypography.metadata,
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
