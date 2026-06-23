import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../data/repositories/providers.dart';

import '../widgets/filter_chip_bar.dart';

class HighLowScreen extends ConsumerStatefulWidget {
  const HighLowScreen({super.key});

  @override
  ConsumerState<HighLowScreen> createState() => _HighLowScreenState();
}

class _HighLowScreenState extends ConsumerState<HighLowScreen> {
  int _filterIndex = 0;
  static const _filterLabels = ['ALL', '< ₹100', '< ₹500', '< ₹1000', '> ₹1000'];

  @override
  Widget build(BuildContext context) {
    final asyncData = ref.watch(highLowProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('52-WEEK HIGHS & LOWS')),
      body: Column(
        children: [
          const SizedBox(height: AppSpacing.sm),
          FilterChipBar(
            labels: _filterLabels,
            selectedIndex: _filterIndex,
            onSelected: (index) => setState(() => _filterIndex = index),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: asyncData.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err', style: AppTypography.bodyMedium)),
              data: (response) {
                if (response.data.isEmpty) {
                  return Center(child: Text('No data found.', style: AppTypography.bodySecondary));
                }
                final model = response.data.first;
                
                // Apply price filter
                List filterList(List items) {
                  if (_filterIndex == 0) return items;
                  return items.where((item) {
                    final price = item.lastPrice ?? 0;
                    if (_filterLabels[_filterIndex] == '< ₹100') return price < 100;
                    if (_filterLabels[_filterIndex] == '< ₹500') return price < 500;
                    if (_filterLabels[_filterIndex] == '< ₹1000') return price < 1000;
                    if (_filterLabels[_filterIndex] == '> ₹1000') return price >= 1000;
                    return true;
                  }).toList();
                }

                final filteredHighs = filterList(model.highs);
                final filteredLows = filterList(model.lows);
                
                return DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      TabBar(
                        indicatorColor: AppColors.primary,
                        labelColor: AppColors.primary,
                        unselectedLabelColor: AppColors.textSecondary,
                        tabs: const [
                          Tab(text: 'Highs 🚀'),
                          Tab(text: 'Lows 📉'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _buildList(filteredHighs, AppColors.success),
                            _buildList(filteredLows, AppColors.danger),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List items, Color color) {
    if (items.isEmpty) {
      return Center(
        child: Text('No stocks in this range.', style: AppTypography.bodySecondary),
      );
    }
    return ListView.separated(
      padding: AppSpacing.screenPadding,
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.border),
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          contentPadding: EdgeInsets.zero,
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
