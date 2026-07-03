import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../data/repositories/providers.dart';
import 'stock_detail_screen.dart';

class CircuitBreakersScreen extends ConsumerWidget {
  const CircuitBreakersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(circuitBreakersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('10%+ CIRCUIT BREAKERS')),
      body: asyncData.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err', style: AppTypography.bodyMedium)),
        data: (response) {
          if (response.data.isEmpty) {
            return Center(child: Text('No circuit breakers found.', style: AppTypography.bodySecondary));
          }
          final model = response.data.first;
          final upperList = model.upperCircuit;
          final lowerList = model.lowerCircuit;

          return DefaultTabController(
            length: 2,
            child: Column(
              children: [
                const TabBar(
                  indicatorColor: AppColors.primary,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textSecondary,
                  tabs: [
                    Tab(text: 'Upper Circuit 🚀 (+10%+)'),
                    Tab(text: 'Lower Circuit 🔻 (-10%+)'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildList(upperList, AppColors.success),
                      _buildList(lowerList, AppColors.danger),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildList(List items, Color color) {
    if (items.isEmpty) {
      return Center(
        child: Text('No stocks currently hit this circuit threshold.', style: AppTypography.bodySecondary),
      );
    }
    return ListView.separated(
      padding: AppSpacing.screenPadding,
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.border),
      itemBuilder: (context, index) {
        final item = items[index];
        final isPositive = (item.changePct ?? 0) >= 0;

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
          subtitle: Text(item.name, style: AppTypography.metadata, maxLines: 1, overflow: TextOverflow.ellipsis),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item.lastPrice != null ? '₹${item.lastPrice}' : '—',
                style: AppTypography.value.copyWith(color: color),
              ),
              Text(
                '${isPositive ? '+' : ''}${item.changePct?.toStringAsFixed(2)}%',
                style: AppTypography.metadata.copyWith(color: color, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      },
    );
  }
}
