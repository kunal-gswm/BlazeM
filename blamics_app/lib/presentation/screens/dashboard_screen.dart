import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../data/repositories/providers.dart';
import '../widgets/fade_switcher.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BLAMICS'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Force refresh all providers
              ref.invalidate(ipoDataProvider);
              ref.invalidate(fiiDiiDataProvider);
              ref.invalidate(corporateActionsProvider);
              ref.invalidate(globalIndicesProvider);
              ref.invalidate(marketBreadthProvider);
              ref.invalidate(earningsCalendarProvider);
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20),
          child: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'MARKET COMMAND CENTER',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    letterSpacing: 1.5,
                  ),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(ipoDataProvider);
          ref.invalidate(fiiDiiDataProvider);
          ref.invalidate(corporateActionsProvider);
          ref.invalidate(globalIndicesProvider);
          ref.invalidate(marketBreadthProvider);
          ref.invalidate(earningsCalendarProvider);
        },
        color: AppColors.primary,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: const [
            _MarketBreadthCard(),
            SizedBox(height: 16),
            _FiiDiiSummaryCard(),
            SizedBox(height: 16),
            _GlobalIndicesMiniBoard(),
          ],
        ),
      ),
    );
  }
}

class _MarketBreadthCard extends ConsumerWidget {
  const _MarketBreadthCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(marketBreadthProvider);
    
    return FadeSwitcher(
      child: asyncData.when(
        loading: () => const Center(key: ValueKey('loading'), child: CircularProgressIndicator()),
        error: (err, stack) => Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Error loading Breadth', style: Theme.of(context).textTheme.bodySmall),
          ),
        ),
        data: (response) {
          if (response.data.isEmpty) return const SizedBox.shrink();
          final breadth = response.data.first;
          
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('MARKET BREADTH', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('ADVANCES', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.positive)),
                            Text('${breadth.up ?? breadth.advance ?? 0}', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.positive, fontSize: 20)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('DECLINES', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.negative)),
                            Text('${breadth.dn ?? breadth.decline ?? 0}', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.negative, fontSize: 20)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Row(
                      children: [
                        Expanded(flex: (breadth.up ?? breadth.advance ?? 0).toInt(), child: Container(color: AppColors.positive)),
                        Expanded(flex: (breadth.dn ?? breadth.decline ?? 0).toInt(), child: Container(color: AppColors.negative)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FiiDiiSummaryCard extends ConsumerWidget {
  const _FiiDiiSummaryCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fiiDiiAsync = ref.watch(fiiDiiDataProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('FII / DII (NET)', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 12),
            FadeSwitcher(
              child: fiiDiiAsync.when(
                loading: () => const Center(key: ValueKey('loading'), child: CircularProgressIndicator()),
                error: (err, stack) => Text('Error: $err', key: const ValueKey('error')),
                data: (response) {
                  if (response.data.isEmpty) return const Text('No data available', key: ValueKey('empty'));
                  return Row(
                    key: const ValueKey('data'),
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: response.data.take(2).map((item) {
                      final isPositive = (item.netValue ?? 0) >= 0;
                      final color = isPositive ? AppColors.positive : AppColors.negative;
                      final sign = isPositive ? '+' : '';
                      
                      return Expanded(
                        child: Row(
                          children: [
                            Text('${item.category} ', style: Theme.of(context).textTheme.bodySmall),
                            Text(
                              '$sign${item.netValue} Cr',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(color: color),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlobalIndicesMiniBoard extends ConsumerWidget {
  const _GlobalIndicesMiniBoard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final indicesAsync = ref.watch(globalIndicesProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('GLOBAL INDICES', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 12),
            FadeSwitcher(
              child: indicesAsync.when(
                loading: () => const Center(key: ValueKey('loading'), child: CircularProgressIndicator()),
                error: (err, stack) => Text('Error: $err', key: const ValueKey('error')),
                data: (response) {
                  return Column(
                    key: const ValueKey('data'),
                    children: response.data.take(3).map((index) {
                      final isPositive = (index.changePct ?? 0) >= 0;
                      final color = isPositive ? AppColors.positive : AppColors.negative;
                      final sign = isPositive ? '+' : '';

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              index.name.toUpperCase().replaceAll(' BSE ', ' '),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Row(
                              children: [
                                Text(
                                  '${index.price}',
                                  style: Theme.of(context).textTheme.labelLarge,
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 70,
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    '$sign${index.changePct}%',
                                    style: Theme.of(context).textTheme.labelLarge?.copyWith(color: color),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
