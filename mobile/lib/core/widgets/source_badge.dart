import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../models/source_meta.dart';

/// Source attribution badge.
///
/// Renders differently based on source priority:
/// P1 (official) = green, P2 (secondary) = blue, P3 (unofficial) = amber.
class SourceBadge extends StatelessWidget {
  const SourceBadge({
    super.key,
    required this.meta,
    this.showLabel = false,
  });

  final SourceMeta meta;

  /// If true, shows "Official" / "Unofficial" label alongside source name.
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final color = switch (meta.sourcePriority) {
      'official' => AppColors.sourceOfficial,
      'secondary' => AppColors.sourceSecondary,
      _ => AppColors.sourceUnofficial,
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          meta.sourceId,
          style: AppTypography.labelSmall.copyWith(color: color),
        ),
        if (showLabel && meta.isUnofficial) ...[
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: AppColors.sourceUnofficial.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              'Unofficial',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.sourceUnofficial,
                fontSize: 9,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
