import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

class StaleBanner extends StatelessWidget {
  final String message;
  final bool isOffline;

  const StaleBanner({
    super.key,
    required this.message,
    this.isOffline = false,
  });

  factory StaleBanner.offline() {
    return const StaleBanner(
      message: 'Showing cached data.',
      isOffline: true,
    );
  }

  factory StaleBanner.stale(String timeAgo) {
    return StaleBanner(
      message: 'Updated $timeAgo',
      isOffline: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      color: isOffline
          ? AppColors.danger.withValues(alpha: 0.1)
          : AppColors.warning.withValues(alpha: 0.1),
      child: Row(
        children: [
          Icon(
            isOffline ? Icons.cloud_off : Icons.access_time,
            size: 14,
            color: isOffline ? AppColors.danger : AppColors.warning,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            message,
            style: AppTypography.metadata.copyWith(
              color: isOffline ? AppColors.danger : AppColors.warning,
            ),
          ),
        ],
      ),
    );
  }
}
