import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../data/repositories/providers.dart';
import '../widgets/fade_switcher.dart';

class MarketsScreen extends ConsumerWidget {
  const MarketsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('MARKETS'),
          bottom: const TabBar(
            isScrollable: true,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            tabs: [
              Tab(text: 'GLOBAL'),
              Tab(text: 'BREADTH'),
              Tab(text: 'EARNINGS'),
              Tab(text: 'IPOS'),
              Tab(text: 'CORP ACTIONS'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _GlobalIndicesTab(),
            _BreadthTab(),
            _EarningsTab(),
            _IposTab(),
            _CorpActionsTab(),
          ],
        ),
      ),
    );
  }
}

class _GlobalIndicesTab extends ConsumerWidget {
  const _GlobalIndicesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(globalIndicesProvider);
    return FadeSwitcher(
      child: asyncData.when(
        loading: () => const Center(key: ValueKey('loading'), child: CircularProgressIndicator()),
        error: (e, st) => _buildErrorState(context, 'Failed to load Global Indices'),
        data: (response) {
          if (response.data.isEmpty) return const Center(key: ValueKey('empty'), child: Text('No data'));
          return ListView.builder(
            key: const ValueKey('data'),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            itemCount: response.data.length,
            itemBuilder: (context, index) {
              final item = response.data[index];
              final isPositive = (item.changePct ?? 0) >= 0;
              final color = isPositive ? AppColors.positive : AppColors.negative;
              
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                    title: Text(item.name.toUpperCase(), style: Theme.of(context).textTheme.titleMedium),
                    subtitle: Text(item.symbol, style: Theme.of(context).textTheme.bodySmall),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('${item.price}', style: Theme.of(context).textTheme.labelLarge),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${isPositive ? '+' : ''}${item.changePct}%',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
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

class _IposTab extends ConsumerWidget {
  const _IposTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(ipoDataProvider);
    return FadeSwitcher(
      child: asyncData.when(
        loading: () => const Center(key: ValueKey('loading'), child: CircularProgressIndicator()),
        error: (e, st) => _buildErrorState(context, 'Failed to load IPO data'),
        data: (response) {
          if (response.data.isEmpty) return const Center(key: ValueKey('empty'), child: Text('No Active IPOs right now.'));
          return ListView.builder(
            key: const ValueKey('data'),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            itemCount: response.data.length,
            itemBuilder: (context, index) {
              final ipo = response.data[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                    title: Text(ipo.issueName.toUpperCase(), style: Theme.of(context).textTheme.titleMedium),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text('Opens: ${ipo.issueOpen ?? 'TBA'}\nCloses: ${ipo.issueClose ?? 'TBA'}', style: Theme.of(context).textTheme.bodyMedium),
                    ),
                    trailing: ipo.gmp != null ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('EST GMP', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 4),
                        Text('₹${ipo.gmp}', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.positive)),
                      ],
                    ) : null,
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

class _CorpActionsTab extends ConsumerWidget {
  const _CorpActionsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(corporateActionsProvider);
    return FadeSwitcher(
      child: asyncData.when(
        loading: () => const Center(key: ValueKey('loading'), child: CircularProgressIndicator()),
        error: (e, st) => _buildErrorState(context, 'Failed to load Corporate Actions'),
        data: (response) {
          if (response.data.isEmpty) return const Center(key: ValueKey('empty'), child: Text('No Corp Actions'));
          return ListView.builder(
            key: const ValueKey('data'),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            itemCount: response.data.length,
            itemBuilder: (context, index) {
              final action = response.data[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                    title: Text(action.shortName, style: Theme.of(context).textTheme.titleMedium),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(action.purpose, style: Theme.of(context).textTheme.bodyMedium),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('EX-DATE', style: TextStyle(color: AppColors.textSecondary, fontSize: 10)),
                        const SizedBox(height: 4),
                        Text(action.exDate ?? '', style: Theme.of(context).textTheme.labelLarge),
                      ],
                    ),
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

class _BreadthTab extends ConsumerWidget {
  const _BreadthTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(marketBreadthProvider);
    return FadeSwitcher(
      child: asyncData.when(
        loading: () => const Center(key: ValueKey('loading'), child: CircularProgressIndicator()),
        error: (e, st) => _buildErrorState(context, 'Failed to load Market Breadth'),
        data: (response) {
          if (response.data.isEmpty) return const Center(key: ValueKey('empty'), child: Text('No Data'));
          return ListView.builder(
            key: const ValueKey('data'),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            itemCount: response.data.length,
            itemBuilder: (context, index) {
              final breadth = response.data[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(breadth.sensInd ?? 'Unknown Index', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStatColumn(context, 'ADVANCES', '${breadth.up ?? breadth.advance ?? 0}', AppColors.positive),
                          _buildStatColumn(context, 'DECLINES', '${breadth.dn ?? breadth.decline ?? 0}', AppColors.negative),
                          _buildStatColumn(context, 'UNCHANGED', '${breadth.uc ?? breadth.unchange ?? 0}', AppColors.textSecondary),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: (breadth.advancePer?.toDouble() ?? 50) / 100,
                        backgroundColor: AppColors.negative,
                        color: AppColors.positive,
                        minHeight: 4,
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
  
  Widget _buildStatColumn(BuildContext context, String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: valueColor)),
      ],
    );
  }
}

class _EarningsTab extends ConsumerWidget {
  const _EarningsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(earningsCalendarProvider);
    return FadeSwitcher(
      child: asyncData.when(
        loading: () => const Center(key: ValueKey('loading'), child: CircularProgressIndicator()),
        error: (e, st) => _buildErrorState(context, 'Failed to load Earnings Calendar'),
        data: (response) {
          if (response.data.isEmpty) return const Center(key: ValueKey('empty'), child: Text('No Upcoming Earnings'));
          return ListView.builder(
            key: const ValueKey('data'),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            itemCount: response.data.length,
            itemBuilder: (context, index) {
              final earning = response.data[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                    title: Text(earning.longName.toUpperCase(), style: Theme.of(context).textTheme.titleMedium),
                    subtitle: Text(earning.shortName, style: Theme.of(context).textTheme.bodySmall),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('MEETING DATE', style: TextStyle(color: AppColors.textSecondary, fontSize: 10)),
                        const SizedBox(height: 4),
                        Text(earning.meetingDate ?? 'TBA', style: Theme.of(context).textTheme.labelLarge),
                      ],
                    ),
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

Widget _buildErrorState(BuildContext context, String message) {
  return Center(
    key: const ValueKey('error'),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.cloud_off, size: 48, color: AppColors.textSecondary),
        const SizedBox(height: 16),
        Text(message, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        const Text('Please check your connection and try again.', style: TextStyle(color: AppColors.textSecondary)),
      ],
    ),
  );
}
