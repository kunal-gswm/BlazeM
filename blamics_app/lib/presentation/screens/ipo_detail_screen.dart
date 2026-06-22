import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/ipo_model.dart';
import '../widgets/metric_row.dart';
import '../widgets/section_header.dart';
import '../widgets/timeline_tile.dart';
import '../../core/constants/app_enums.dart';

class IpoDetailScreen extends StatelessWidget {
  final IpoModel ipo;

  const IpoDetailScreen({super.key, required this.ipo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          ipo.issueName.toUpperCase(),
          style: AppTypography.sectionTitle,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: AppSpacing.screenPadding,
        children: [
          // ── Overview ────────────────────────────────────────────────
          const SectionHeader(title: 'Overview'),
          _InfoBlock(
            children: [
              MetricRow(label: 'Issue Name', value: ipo.issueName),
              MetricRow(label: 'Type', value: ipo.ipoType),
              MetricRow(label: 'Price Band', value: ipo.priceBand),
              MetricRow(label: 'Lot Size', value: ipo.lotSize),
              MetricRow(label: 'Issue Size', value: ipo.issueSize),
            ],
          ),

          AppSpacing.sectionGap,

          // ── Dates ───────────────────────────────────────────────────
          const SectionHeader(title: 'Dates'),
          _InfoBlock(
            children: [
              MetricRow(
                label: 'Issue Open',
                value: ipo.issueOpen ?? 'TBA',
              ),
              MetricRow(
                label: 'Issue Close',
                value: ipo.issueClose ?? 'TBA',
              ),
              MetricRow(
                label: 'Allotment',
                value: ipo.allotmentDate ?? 'TBA',
              ),
              MetricRow(
                label: 'Listing',
                value: ipo.listingDate ?? 'TBA',
              ),
            ],
          ),

          AppSpacing.sectionGap,

          // ── GMP ─────────────────────────────────────────────────────
          const SectionHeader(title: 'Grey Market Premium'),
          _InfoBlock(
            children: [
              MetricRow(
                label: 'Estimated GMP',
                value: ipo.gmp != null ? '₹${ipo.gmp!.toStringAsFixed(2)}' : 'N/A',
                valueColor: ipo.gmp != null ? (ipo.gmp! >= 0 ? AppColors.success : AppColors.danger) : null,
              ),
              MetricRow(
                label: 'Est. Return',
                value: ipo.calculatedGmpPercent,
                valueColor: ipo.gmp != null ? (ipo.gmp! >= 0 ? AppColors.success : AppColors.danger) : null,
              ),
            ],
          ),

          AppSpacing.sectionGap,

          // ── Timeline ────────────────────────────────────────────────
          const SectionHeader(title: 'Milestones'),
          _buildTimeline(),

          AppSpacing.sectionGap,

          // ── Issue Details ───────────────────────────────────────────
          const SectionHeader(title: 'Issue Details'),
          _InfoBlock(
            children: [
              MetricRow(label: 'Source', value: ipo.source),
              MetricRow(label: 'IPO Type', value: ipo.ipoType),
            ],
          ),

          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    final milestones = <_Milestone>[];

    if (ipo.issueOpen != null) {
      milestones.add(_Milestone('Issue Opens', ipo.issueOpen!, ImportanceLevel.high));
    }
    if (ipo.issueClose != null) {
      milestones.add(_Milestone('Issue Closes', ipo.issueClose!, ImportanceLevel.high));
    }
    if (ipo.allotmentDate != null) {
      milestones.add(_Milestone('Allotment', ipo.allotmentDate!, ImportanceLevel.medium));
    }
    if (ipo.listingDate != null) {
      milestones.add(_Milestone('Listing', ipo.listingDate!, ImportanceLevel.critical));
    }

    if (milestones.isEmpty) {
      return Container(
        padding: AppSpacing.cardPadding,
        decoration: BoxDecoration(
          color: AppColors.surface1,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Text(
          'No milestone dates available.',
          style: AppTypography.bodySecondary,
        ),
      );
    }

    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.surface1,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        children: List.generate(milestones.length, (index) {
          final m = milestones[index];
          return TimelineTile(
            title: m.title,
            entity: m.date,
            importance: m.importance,
            isLast: index == milestones.length - 1,
          );
        }),
      ),
    );
  }
}

class _Milestone {
  final String title;
  final String date;
  final ImportanceLevel importance;

  _Milestone(this.title, this.date, this.importance);
}

class _InfoBlock extends StatelessWidget {
  final List<Widget> children;

  const _InfoBlock({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.surface1,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}
