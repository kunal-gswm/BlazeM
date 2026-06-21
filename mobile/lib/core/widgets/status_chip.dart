import 'package:flutter/material.dart';
import '../models/timeline_event.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Chip displaying event status with semantic coloring.
class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.status,
  });

  final EventStatus status;

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status) {
      EventStatus.upcoming => (AppColors.statusUpcoming, 'Upcoming'),
      EventStatus.active => (AppColors.statusActive, 'Active'),
      EventStatus.completed => (AppColors.statusCompleted, 'Completed'),
      EventStatus.cancelled => (AppColors.statusCancelled, 'Cancelled'),
      EventStatus.withdrawn => (AppColors.statusCancelled, 'Withdrawn'),
      EventStatus.changed => (AppColors.statusUpcoming, 'Changed'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
