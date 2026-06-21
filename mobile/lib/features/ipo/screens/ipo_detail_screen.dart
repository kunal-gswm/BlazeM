import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/data_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/shimmer_loader.dart';
import '../../../core/widgets/source_badge.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../core/extensions/date_extensions.dart';
import '../providers/ipo_providers.dart';
import '../models/ipo_model.dart';

class IpoDetailScreen extends ConsumerWidget {
  const IpoDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(ipoDetailProvider(id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('IPO Details'),
      ),
      body: stateAsync.when(
        data: (state) => _buildBody(context, state),
        error: (err, _) => ErrorView(message: err.toString()),
        loading: () => Padding(
          padding: const EdgeInsets.all(16),
          child: ShimmerLoader.block(height: 200),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, DataState<IpoModel> state) {
    return switch (state) {
      DataLoading() => Padding(
          padding: const EdgeInsets.all(16),
          child: ShimmerLoader.block(height: 200),
        ),
      DataError(:final message) => ErrorView(message: message),
      DataFresh(:final data) || DataStale(:final data) => _buildDetail(context, data),
    };
  }

  Widget _buildDetail(BuildContext context, IpoModel ipo) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  ipo.companyName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              StatusChip(status: ipo.status),
            ],
          ),
          if (ipo.symbol != null) ...[
            const SizedBox(height: 4),
            Text(
              ipo.symbol!,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
          
          const SizedBox(height: 16),
          SourceBadge(meta: ipo.meta),
          const SizedBox(height: 24),

          // Key Metrics Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Key Metrics',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildMetric(context, 'Issue Size', '₹${ipo.issueSize?.toStringAsFixed(0) ?? '-'} Cr'),
                    _buildMetric(context, 'Price Band', '₹${ipo.issuePriceMin?.toStringAsFixed(0)}-${ipo.issuePriceMax?.toStringAsFixed(0)}'),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildMetric(context, 'Lot Size', '${ipo.lotSize ?? '-'} shares'),
                    _buildMetric(context, 'Retail Quota', '${ipo.retailQuota?.toStringAsFixed(0) ?? '-'}%'),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),

          // Timeline Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Timeline',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                _buildTimelineRow(context, 'Open Date', ipo.openDate?.formatted ?? '-'),
                const Divider(height: 24, color: AppColors.border),
                _buildTimelineRow(context, 'Close Date', ipo.closeDate?.formatted ?? '-'),
                const Divider(height: 24, color: AppColors.border),
                _buildTimelineRow(context, 'Allotment', ipo.allotmentDate?.formatted ?? '-'),
                const Divider(height: 24, color: AppColors.border),
                _buildTimelineRow(context, 'Listing', ipo.listingDate?.formatted ?? '-'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(BuildContext context, String label, String value) {
    return Expanded(
      child: Column(
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
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineRow(BuildContext context, String label, String date) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        Text(
          date,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
