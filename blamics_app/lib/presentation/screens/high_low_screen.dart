import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../data/repositories/providers.dart';
import '../../data/repositories/watchlist_provider.dart';

import '../widgets/filter_chip_bar.dart';
import 'stock_detail_screen.dart';

class HighLowScreen extends ConsumerStatefulWidget {
  const HighLowScreen({super.key});

  @override
  ConsumerState<HighLowScreen> createState() => _HighLowScreenState();
}

class _HighLowScreenState extends ConsumerState<HighLowScreen> {
  int _filterIndex = 0;
  String _searchQuery = '';
  static const _filterLabels = ['ALL', '< ₹100', '< ₹500', '< ₹1000', '> ₹1000'];

  @override
  Widget build(BuildContext context) {
    final asyncData = ref.watch(highLowProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('52-WEEK HIGHS & LOWS')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: CupertinoSearchTextField(
              backgroundColor: AppColors.surface1,
              style: AppTypography.bodyMedium,
              placeholderStyle: AppTypography.bodySecondary,
              onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
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
                
                // Apply price & search filter
                List filterList(List items) {
                  var filtered = items;
                  
                  // Search filter
                  if (_searchQuery.isNotEmpty) {
                    filtered = filtered.where((item) {
                      return item.symbol.toLowerCase().contains(_searchQuery) ||
                             item.companyName.toLowerCase().contains(_searchQuery);
                    }).toList();
                  }

                  // Price filter
                  if (_filterIndex != 0) {
                    filtered = filtered.where((item) {
                      final price = item.lastPrice ?? 0;
                      if (_filterLabels[_filterIndex] == '< ₹100') return price < 100;
                      if (_filterLabels[_filterIndex] == '< ₹500') return price < 500;
                      if (_filterLabels[_filterIndex] == '< ₹1000') return price < 1000;
                      if (_filterLabels[_filterIndex] == '> ₹1000') return price >= 1000;
                      return true;
                    }).toList();
                  }
                  
                  return filtered;
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
        final itemId = 'STOCK:${item.symbol}';
        
        // Watchlist state
        ref.watch(watchlistProvider);
        final isSaved = ref.read(watchlistProvider.notifier).isSaved(itemId);

        return ListTile(
          contentPadding: EdgeInsets.zero,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => StockDetailScreen(symbol: item.symbol),
              ),
            );
          },
          title: Text(item.symbol, style: AppTypography.bodyMedium),
          subtitle: Text(item.companyName, style: AppTypography.metadata, maxLines: 1, overflow: TextOverflow.ellipsis),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
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
              const SizedBox(width: AppSpacing.sm),
              GestureDetector(
                onTap: () {
                  ref.read(watchlistProvider.notifier).toggleItem(
                    WatchlistItem(
                      id: itemId,
                      title: item.symbol,
                      type: 'STOCK',
                      subtitle: item.companyName,
                    ),
                  );
                },
                child: Icon(
                  isSaved ? Icons.star_rounded : Icons.star_border_rounded,
                  color: isSaved ? Colors.amber : AppColors.textSecondary,
                  size: 24,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
