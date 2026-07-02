import 'package:flutter/material.dart';
import '../../core/constants/app_enums.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import 'importance_indicator.dart';

class EventCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? date;
  final ImportanceLevel importance;
  final String? source;
  final VoidCallback? onTap;
  final double? dividendAmount;

  const EventCard({
    super.key,
    required this.title,
    this.subtitle,
    this.date,
    this.importance = ImportanceLevel.medium,
    this.source,
    this.onTap,
    this.dividendAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Material(
        color: AppColors.surface1,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 76,
            child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Importance indicator bar
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppSpacing.cardRadius),
                bottomLeft: Radius.circular(AppSpacing.cardRadius),
              ),
              child: ImportanceIndicator(level: importance),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Center: Title/Subtitle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            title,
                            style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              subtitle!,
                              style: AppTypography.bodySecondary.copyWith(fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    // Right: Date/Status
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (date != null)
                          Text(
                            date!,
                            style: AppTypography.value.copyWith(fontSize: 13),
                          ),
                        if (dividendAmount != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            '₹${dividendAmount!.toStringAsFixed(2)}',
                            style: AppTypography.metadata.copyWith(
                              color: AppColors.success,
                            ),
                          ),
                        ],
                        if (source != null) ...[
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.surface2,
                              borderRadius: BorderRadius.circular(AppSpacing.badgeRadius),
                            ),
                            child: Text(
                              source!.toUpperCase(),
                              style: AppTypography.metadata.copyWith(fontSize: 9),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
          ),
        ),
      ),
    );
  }
}
