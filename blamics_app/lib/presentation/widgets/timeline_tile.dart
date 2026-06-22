import 'package:flutter/material.dart';
import '../../core/constants/app_enums.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

class TimelineTile extends StatelessWidget {
  final String title;
  final String entity;
  final String? date;
  final ImportanceLevel importance;
  final bool isLast;

  const TimelineTile({
    super.key,
    required this.title,
    required this.entity,
    this.date,
    this.importance = ImportanceLevel.medium,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline connector
          SizedBox(
            width: 20,
            child: Column(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 6),
                  decoration: BoxDecoration(
                    color: importance.color,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1,
                      color: AppColors.border,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    entity,
                    style: AppTypography.bodySecondary.copyWith(fontSize: 13),
                  ),
                  if (date != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      date!,
                      style: AppTypography.timestamp,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
