import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_enums.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/ipo_model.dart';
import '../../data/repositories/providers.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_state.dart';
import '../widgets/fade_switcher.dart';
import '../widgets/skeleton_loader.dart';
import '../widgets/status_badge.dart';
import 'ipo_detail_screen.dart';

class IpoListScreen extends ConsumerWidget {
  const IpoListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(ipoDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('IPOs'),
      ),
      body: FadeSwitcher(
        child: asyncData.when(
          loading: () => Padding(
            key: const ValueKey('loading'),
            padding: AppSpacing.screenPadding,
            child: const SkeletonLoader(itemCount: 5, itemHeight: 80),
          ),
          error: (err, _) => ErrorState(
            key: const ValueKey('error'),
            message: 'Failed to load IPO data.',
            onRetry: () => ref.invalidate(ipoDataProvider),
          ),
          data: (response) {
            if (response.data.isEmpty) {
              return const EmptyState(
                key: ValueKey('empty'),
                icon: Icons.rocket_launch_outlined,
                message: 'No active IPOs right now.',
                submessage: 'Check back later for upcoming issues.',
              );
            }

            return ListView.builder(
              key: const ValueKey('data'),
              padding: AppSpacing.screenPadding,
              itemCount: response.data.length,
              itemBuilder: (context, index) {
                final ipo = response.data[index];
                return _IpoRow(ipo: ipo);
              },
            );
          },
        ),
      ),
    );
  }
}

class _IpoRow extends StatelessWidget {
  final IpoModel ipo;

  const _IpoRow({required this.ipo});

  IpoStatus _determineStatus(IpoModel ipo) {
    // Simple heuristic based on available dates
    if (ipo.listingDate != null && ipo.listingDate!.isNotEmpty) {
      return IpoStatus.listed;
    }
    if (ipo.issueClose != null && ipo.issueClose!.isNotEmpty) {
      // Could check if close date has passed, but we don't have a reliable
      // date parser for all formats here, so we infer from data presence
      if (ipo.allotmentDate != null && ipo.allotmentDate!.isNotEmpty) {
        return IpoStatus.closed;
      }
      return IpoStatus.open;
    }
    return IpoStatus.upcoming;
  }

  @override
  Widget build(BuildContext context) {
    final status = _determineStatus(ipo);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => IpoDetailScreen(ipo: ipo),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: AppSpacing.cardPadding,
        decoration: BoxDecoration(
          color: AppColors.surface1,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title + Status badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    ipo.issueName.toUpperCase(),
                    style: AppTypography.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                StatusBadge(status: status),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            // Metadata line
            Row(
              children: [
                if (ipo.gmp != null) ...[
                  Text(
                    'GMP ₹${ipo.gmp?.toStringAsFixed(2)} (${ipo.calculatedGmpPercent})',
                    style: AppTypography.metadata.copyWith(
                      color: ipo.gmp! >= 0 ? AppColors.success : AppColors.danger,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                ],
                if (ipo.issueOpen != null)
                  Text(
                    'Open: ${ipo.issueOpen}',
                    style: AppTypography.timestamp,
                  ),
                if (ipo.issueClose != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Close: ${ipo.issueClose}',
                    style: AppTypography.timestamp,
                  ),
                ],
              ],
            ),
            if (ipo.listingDate != null) ...[
              const SizedBox(height: 2),
              Text(
                'Listing: ${ipo.listingDate}',
                style: AppTypography.timestamp,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
