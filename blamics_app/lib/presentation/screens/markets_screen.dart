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
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('MARKETS'),
          bottom: const TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            tabs: [
              Tab(text: 'GLOBAL'),
              Tab(text: 'IPOS'),
              Tab(text: 'CORP ACTIONS'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _GlobalIndicesTab(),
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
        error: (e, st) => Center(key: const ValueKey('error'), child: Text('Error: $e')),
        data: (response) {
          if (response.data.isEmpty) return const Center(key: ValueKey('empty'), child: Text('No data'));
          return ListView.separated(
            key: const ValueKey('data'),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: response.data.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final item = response.data[index];
            final isPositive = (item.changePct ?? 0) >= 0;
            final color = isPositive ? AppColors.positive : AppColors.negative;
            
            return ListTile(
              title: Text(item.name.toUpperCase()),
              subtitle: Text(item.symbol),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${item.price}', style: Theme.of(context).textTheme.labelLarge),
                  Text(
                    '${isPositive ? '+' : ''}${item.changePct}%',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: color),
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

class _IposTab extends ConsumerWidget {
  const _IposTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(ipoDataProvider);
    return FadeSwitcher(
      child: asyncData.when(
        loading: () => const Center(key: ValueKey('loading'), child: CircularProgressIndicator()),
        error: (e, st) => Center(key: const ValueKey('error'), child: Text('Error: $e')),
        data: (response) {
          if (response.data.isEmpty) return const Center(key: ValueKey('empty'), child: Text('No IPOs Active'));
          return ListView.builder(
            key: const ValueKey('data'),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: response.data.length,
          itemBuilder: (context, index) {
            final ipo = response.data[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(ipo.issueName.toUpperCase(), style: Theme.of(context).textTheme.titleMedium),
                subtitle: Text('Opens: ${ipo.issueOpen ?? 'TBA'} | Closes: ${ipo.issueClose ?? 'TBA'}'),
                trailing: ipo.gmp != null ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('GMP', style: TextStyle(color: AppColors.textSecondary, fontSize: 10)),
                    Text('₹${ipo.gmp}', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.positive)),
                  ],
                ) : null,
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
        error: (e, st) => Center(key: const ValueKey('error'), child: Text('Error: $e')),
        data: (response) {
          if (response.data.isEmpty) return const Center(key: ValueKey('empty'), child: Text('No Corp Actions'));
          return ListView.separated(
            key: const ValueKey('data'),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: response.data.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final action = response.data[index];
            return ListTile(
              title: Text(action.shortName),
              subtitle: Text(action.purpose),
              trailing: Text(action.exDate ?? '', style: Theme.of(context).textTheme.bodySmall),
            );
          },
        );
      },
      ),
    );
  }
}
