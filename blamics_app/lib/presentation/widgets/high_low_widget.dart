import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../data/repositories/providers.dart';

class HighLowWidget extends ConsumerWidget {
  const HighLowWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(highLowProvider);

    return asyncData.when(
      loading: () => const SizedBox.shrink(),
      error: (err, stack) => const SizedBox.shrink(),
      data: (response) {
        if (response.data.isEmpty) return const SizedBox.shrink();
        final model = response.data.first;
        
        return DefaultTabController(
          length: 2,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface1,
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Text('52-Week Extremes', style: AppTypography.sectionTitle),
                ),
                TabBar(
                  indicatorColor: AppColors.primary,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textSecondary,
                  tabs: const [
                    Tab(text: 'Highs 🚀'),
                    Tab(text: 'Lows 📉'),
                  ],
                ),
                SizedBox(
                  height: 250,
                  child: TabBarView(
                    children: [
                      _buildList(model.highs, AppColors.success),
                      _buildList(model.lows, AppColors.error),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildList(List items, Color color) {
    if (items.isEmpty) {
      return Center(
        child: Text('No data found.', style: AppTypography.bodySecondary),
      );
    }
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.border),
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          title: Text(item.symbol, style: AppTypography.bodyMedium),
          subtitle: Text(item.companyName, style: AppTypography.metadata, maxLines: 1, overflow: TextOverflow.ellipsis),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item.lastPrice != null ? '₹${item.lastPrice}' : '—',
                style: AppTypography.value.copyWith(color: color),
              ),
              Text(
                item.value52Week != null ? '52W: ₹${item.value52Week}' : '',
                style: AppTypography.metadata,
              ),
            ],
          ),
        );
      },
    );
  }
}
