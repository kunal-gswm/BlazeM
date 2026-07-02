import 'package:flutter/material.dart';
import '../../core/constants/app_enums.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

class StatusBadge extends StatelessWidget {
  final IpoStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: status.color,
        borderRadius: BorderRadius.circular(AppSpacing.badgeRadius),
      ),
      child: Text(
        status.label.toUpperCase(),
        style: AppTypography.metadata.copyWith(
          color: AppColors.background,
          fontWeight: FontWeight.bold,
          fontSize: 10,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
