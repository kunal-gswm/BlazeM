import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../data/repositories/providers.dart';
import 'stock_detail_screen.dart';

class VolumeShockerScreen extends ConsumerWidget {
  const VolumeShockerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(volumeShockerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('VOLUME SHOCKERS ⚡')),
      body: asyncData.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err', style: AppTypography.bodyMedium)),
        data: (response) {
          final shockers = response.data;
          if (shockers.isEmpty) {
            return Center(child: Text('No volume shockers found.', style: AppTypography.bodySecondary));
          }

          return ListView.separated(
            padding: AppSpacing.screenPadding,
            itemCount: shockers.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final item = shockers[index];
              final isPositive = (item.changePct ?? 0) >= 0;
              final color = isPositive ? AppColors.success : AppColors.danger;

              return InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => StockDetailScreen(symbol: item.symbol),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.surface1,
                    borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.symbol, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 2),
                            Text(item.name, style: AppTypography.metadata, maxLines: 1, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: AppSpacing.sm),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    item.volChange1WkPct != null ? '1W Vol: +${item.volChange1WkPct!.toStringAsFixed(0)}%' : 'High Vol',
                                    style: AppTypography.metadata.copyWith(color: Colors.amber, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  item.turnoverCr != null ? 'Turnover: ₹${item.turnoverCr!.toStringAsFixed(1)} Cr' : '',
                                  style: AppTypography.metadata,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            item.lastPrice != null ? '₹${item.lastPrice}' : '—',
                            style: AppTypography.screenTitle.copyWith(fontSize: 18),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${isPositive ? '+' : ''}${item.changePct?.toStringAsFixed(2)}%',
                              style: AppTypography.metadata.copyWith(
                                color: color,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
