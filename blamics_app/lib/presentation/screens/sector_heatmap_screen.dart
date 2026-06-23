import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../data/repositories/providers.dart';

class SectorHeatmapScreen extends ConsumerWidget {
  const SectorHeatmapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(sectorPerformanceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('SECTOR HEATMAP')),
      body: asyncData.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err', style: AppTypography.bodyMedium)),
        data: (response) {
          final sectors = response.data;
          if (sectors.isEmpty) {
            return Center(child: Text('No data found.', style: AppTypography.bodySecondary));
          }
          
          return GridView.builder(
            padding: AppSpacing.screenPadding,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppSpacing.sm,
              mainAxisSpacing: AppSpacing.sm,
              childAspectRatio: 1.5,
            ),
            itemCount: sectors.length,
            itemBuilder: (context, index) {
              final sector = sectors[index];
              final isPositive = (sector.percentChange ?? 0) >= 0;
              
              final intensity = ((sector.percentChange ?? 0).abs() / 3.0).clamp(0.1, 1.0);
              
              final color = isPositive 
                  ? AppColors.success.withValues(alpha: intensity) 
                  : AppColors.danger.withValues(alpha: intensity);
                  
              final textColor = isPositive ? AppColors.success : AppColors.danger;

              return Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
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
                        fontSize: 18,
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
          );
        },
      ),
    );
  }
}
