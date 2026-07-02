import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../data/repositories/providers.dart';

class MenuScreen extends ConsumerWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthAsync = ref.watch(healthStatusProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('MENU'),
      ),
      body: ListView(
        padding: AppSpacing.screenPadding,
        children: [
          // App identity
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BLAMICS',
                  style: AppTypography.screenTitle,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Market Intelligence Terminal',
                  style: AppTypography.bodySecondary,
                ),
              ],
            ),
          ),

          const Divider(),

          _MenuTile(
            icon: Icons.info_outline,
            title: 'About',
            subtitle: 'Version 1.0.0',
            onTap: () {},
          ),
          _MenuTile(
            icon: Icons.storage_outlined,
            title: 'Data Sources',
            subtitle: 'BSE API, NSE, IPO feeds',
            onTap: () {},
          ),
          _MenuTile(
            icon: Icons.refresh,
            title: 'Refresh Interval',
            subtitle: 'On-demand refresh',
            onTap: () {},
          ),
          _MenuTile(
            icon: Icons.delete_outline,
            title: 'Clear Cache',
            subtitle: 'Remove cached data',
            onTap: () {},
          ),

          const Divider(),

          // Data freshness info
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DATA STATUS',
                  style: AppTypography.label.copyWith(letterSpacing: 1.5),
                ),
                const SizedBox(height: AppSpacing.sm),
                ...healthAsync.when(
                  loading: () => [const Center(child: CircularProgressIndicator())],
                  error: (_, __) => [const Text('Unable to load health status')],
                  data: (healthMap) {
                    const pipelineLabels = {
                      'corporate_actions': 'Corporate Actions',
                      'earnings_calendar': 'Earnings Calendar',
                      'fii_dii': 'FII / DII',
                      'market_breadth': 'Market Breadth',
                      'global_indices': 'Global Indices',
                      'ipos': 'IPO Data',
                      'sector_performance': 'Sector Performance',
                      'market_sentiment': 'Market Sentiment',
                      'high_low': '52W High/Low',
                    };
                    return pipelineLabels.entries.map((e) {
                      final status = healthMap[e.key]?['status'] ?? 'unknown';
                      final displayStatus = status == 'healthy' ? 'Live' : 'Failed';
                      return _StatusRow(label: e.value, status: displayStatus);
                    }).toList();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.textSecondary),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.bodyMedium),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTypography.timestamp),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final String label;
  final String status;

  const _StatusRow({
    required this.label,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final isLive = status == 'Live';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodySecondary.copyWith(fontSize: 13)),
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isLive ? AppColors.success : AppColors.danger,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                status,
                style: AppTypography.metadata.copyWith(
                  color: isLive ? AppColors.success : AppColors.danger,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
