import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../data/repositories/watchlist_provider.dart';
import '../../data/repositories/providers.dart';
import '../widgets/empty_state.dart';
import 'stock_detail_screen.dart';
import 'ipo_detail_screen.dart';

class WatchlistScreen extends ConsumerWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watchItems = ref.watch(watchlistProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('WATCHLIST')),
      body: watchItems.isEmpty
          ? const EmptyState(
              icon: Icons.star_border_rounded,
              message: 'No saved items',
              submessage: 'Tap the star icon on IPOs or Stocks to save them here.',
            )
          : ListView.builder(
              padding: AppSpacing.screenPadding,
              itemCount: watchItems.length,
              itemBuilder: (context, index) {
                final item = watchItems[index];
                
                return Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.surface1,
                    borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: ListTile(
                    contentPadding: AppSpacing.cardPadding,
                    title: Text(item.title, style: AppTypography.bodyMedium),
                    subtitle: item.subtitle != null 
                        ? Text(item.subtitle!, style: AppTypography.metadata)
                        : null,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.surface2,
                            borderRadius: BorderRadius.circular(AppSpacing.badgeRadius),
                          ),
                          child: Text(
                            item.type,
                            style: AppTypography.timestamp,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        IconButton(
                          icon: const Icon(Icons.star_rounded, color: Colors.amber),
                          onPressed: () => ref.read(watchlistProvider.notifier).toggleItem(item),
                        ),
                      ],
                    ),
                    onTap: () async {
                      if (item.type == 'STOCK') {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => StockDetailScreen(symbol: item.title)));
                      } else if (item.type == 'IPO') {
                        try {
                          final ipoResponse = await ref.read(ipoDataProvider.future);
                          final ipoModel = ipoResponse.data.firstWhere(
                            (ipo) => ipo.issueName == item.title,
                          );
                          if (context.mounted) {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => IpoDetailScreen(ipo: ipoModel)));
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('IPO details not available offline.')),
                            );
                          }
                        }
                      }
                    },
                  ),
                );
              },
            ),
    );
  }
}
