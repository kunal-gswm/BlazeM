import 'package:flutter/material.dart';
import '../models/timeline_event.dart';
import '../extensions/date_extensions.dart';
import '../theme/app_colors.dart';
import 'source_badge.dart';
import 'status_chip.dart';

class EventTimelineCard extends StatelessWidget {
  const EventTimelineCard({
    super.key,
    required this.event,
    this.onTap,
  });

  final TimelineEvent event;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Date & Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      _getIconForEntityType(event.entityType),
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      event.date.toRelativeOrDate(),
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: _getDateColor(event),
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
                StatusChip(status: event.status),
              ],
            ),
            const SizedBox(height: 12),
            
            // Title & Subtitle
            Text(
              event.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            if (event.subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                event.subtitle!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Bottom Row: Importance & Source
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildImportanceIndicator(context),
                SourceBadge(meta: event.meta),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForEntityType(EntityType type) {
    return switch (type) {
      EntityType.ipo => Icons.rocket_launch,
      EntityType.corporateAction => Icons.event_note,
      EntityType.bond => Icons.account_balance,
      EntityType.news => Icons.article,
      EntityType.event => Icons.bolt,
    };
  }

  Color _getDateColor(TimelineEvent event) {
    // If the event is today, make it pop.
    if (event.date.isToday) {
      return AppColors.warning; // or a specific highlight color
    }
    return AppColors.textSecondary;
  }

  Widget _buildImportanceIndicator(BuildContext context) {
    final color = switch (event.importance) {
      EventImportance.critical => AppColors.negative,
      EventImportance.high => AppColors.warning,
      EventImportance.medium => AppColors.info,
      EventImportance.low => AppColors.textSecondary,
    };

    return Row(
      children: [
        Icon(Icons.circle, size: 8, color: color),
        const SizedBox(width: 6),
        Text(
          event.importance.name.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
        ),
      ],
    );
  }
}
