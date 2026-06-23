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
import '../widgets/filter_chip_bar.dart';
import 'ipo_detail_screen.dart';

// Helper to determine status based on live dates
IpoStatus _determineStatus(IpoModel ipo) {
  final now = DateTime.now();
  
  DateTime? parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      return null;
    }
  }

  final today = DateTime(now.year, now.month, now.day);
  
  final listingDate = parseDate(ipo.listingDate);
  final closeDate = parseDate(ipo.issueClose);
  final openDate = parseDate(ipo.issueOpen);
  
  if (listingDate != null && (listingDate.isBefore(today) || listingDate.isAtSameMomentAs(today))) {
    return IpoStatus.listed;
  }
  
  if (closeDate != null && (closeDate.isBefore(today) || closeDate.isAtSameMomentAs(today))) {
    return IpoStatus.closed;
  }
  
  if (openDate != null && (openDate.isBefore(today) || openDate.isAtSameMomentAs(today))) {
    return IpoStatus.open;
  }
  
  return IpoStatus.upcoming;
}

class IpoListScreen extends ConsumerStatefulWidget {
  const IpoListScreen({super.key});

  @override
  ConsumerState<IpoListScreen> createState() => _IpoListScreenState();
}

class _IpoListScreenState extends ConsumerState<IpoListScreen> {
  int _filterIndex = 0;
  static const _filterLabels = ['ALL', 'OPEN', 'UPCOMING', 'CLOSED', 'LISTED'];

  @override
  Widget build(BuildContext context) {
    final asyncData = ref.watch(ipoDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('IPOs'),
      ),
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
            child: FadeSwitcher(
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
                  final allIpos = response.data;
                  if (allIpos.isEmpty) {
                    return const EmptyState(
                      key: ValueKey('empty'),
                      icon: Icons.rocket_launch_outlined,
                      message: 'No active IPOs right now.',
                      submessage: 'Check back later for upcoming issues.',
                    );
                  }

                  // Apply filter
                  final filtered = _filterIndex == 0
                      ? allIpos
                      : allIpos.where((ipo) {
                          final status = _determineStatus(ipo);
                          final filterName = _filterLabels[_filterIndex];
                          if (filterName == 'OPEN' && status == IpoStatus.open) return true;
                          if (filterName == 'UPCOMING' && status == IpoStatus.upcoming) return true;
                          if (filterName == 'CLOSED' && status == IpoStatus.closed) return true;
                          if (filterName == 'LISTED' && status == IpoStatus.listed) return true;
                          return false;
                        }).toList();

                  if (filtered.isEmpty) {
                    return EmptyState(
                      key: const ValueKey('filtered_empty'),
                      icon: Icons.filter_alt_off_outlined,
                      message: 'No IPOs match this filter.',
                    );
                  }

                  return ListView.builder(
                    key: const ValueKey('data'),
                    padding: AppSpacing.screenPadding,
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final ipo = filtered[index];
                      return _IpoRow(ipo: ipo);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IpoRow extends StatelessWidget {
  final IpoModel ipo;

  const _IpoRow({required this.ipo});

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
