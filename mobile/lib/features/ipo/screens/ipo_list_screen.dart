import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/data_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/shimmer_loader.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../core/extensions/date_extensions.dart';
import '../../../routing/route_names.dart';
import '../providers/ipo_providers.dart';
import '../models/ipo_model.dart';

class IpoListScreen extends ConsumerWidget {
  const IpoListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(ipoListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('IPOs'),
      ),
      body: stateAsync.when(
        data: (state) => _buildBody(context, state),
        error: (err, _) => ErrorView(
          message: err.toString(),
          onRetry: () => ref.invalidate(ipoListProvider),
        ),
        loading: () => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: 8,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, __) => ShimmerLoader.block(height: 100),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, DataState<List<IpoModel>> state) {
    return switch (state) {
      DataLoading() => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: 8,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, __) => ShimmerLoader.block(height: 100),
        ),
      DataError(:final message) => ErrorView(message: message),
      DataFresh(:final data) || DataStale(:final data) => _buildList(context, data),
    };
  }

  Widget _buildList(BuildContext context, List<IpoModel> ipos) {
    if (ipos.isEmpty) {
      return const Center(child: Text('No IPOs found.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: ipos.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final ipo = ipos[index];
        return InkWell(
          onTap: () {
            context.goNamed(RouteNames.ipoDetail, pathParameters: {'id': ipo.id});
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        ipo.companyName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    StatusChip(status: ipo.status),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoColumn(context, 'Issue Size', '₹${ipo.issueSize?.toStringAsFixed(0) ?? '-'} Cr'),
                    _buildInfoColumn(context, 'Price Band', '₹${ipo.issuePriceMin?.toStringAsFixed(0)}-${ipo.issuePriceMax?.toStringAsFixed(0)}'),
                    _buildInfoColumn(context, 'Close Date', ipo.closeDate?.shortFormatted ?? '-'),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoColumn(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
        ),
      ],
    );
  }
}
