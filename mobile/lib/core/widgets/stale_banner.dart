import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Banner shown when data is past its TTL.
///
/// Shows relative time since last fetch, optional refresh spinner,
/// and source attribution. Tappable to force refresh.
class StaleBanner extends StatelessWidget {
  const StaleBanner({
    super.key,
    required this.fetchedAt,
    this.source,
    this.isRefreshing = false,
    this.onRefresh,
  });

  final DateTime fetchedAt;
  final String? source;
  final bool isRefreshing;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onRefresh,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        color: AppColors.staleBannerBg,
        child: Row(
          children: [
            Icon(
              Icons.access_time,
              size: 13,
              color: AppColors.staleBannerText,
            ),
            const SizedBox(width: 6),
            Text(
              _formatAge(fetchedAt),
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.staleBannerText,
              ),
            ),
            if (source != null) ...[
              Text(
                ' · $source',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.staleBannerText,
                ),
              ),
            ],
            const Spacer(),
            if (isRefreshing)
              const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  color: AppColors.staleBannerText,
                ),
              )
            else
              Icon(
                Icons.refresh,
                size: 14,
                color: AppColors.staleBannerText,
              ),
          ],
        ),
      ),
    );
  }

  String _formatAge(DateTime fetchedAt) {
    final diff = DateTime.now().difference(fetchedAt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return 'Updated ${diff.inMinutes}m ago';
    if (diff.inHours < 24) return 'Updated ${diff.inHours}h ago';
    return 'Updated ${diff.inDays}d ago';
  }
}
