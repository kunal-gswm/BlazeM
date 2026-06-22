import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../data/repositories/providers.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_state.dart';
import '../widgets/fade_switcher.dart';
import '../widgets/skeleton_loader.dart';

class CorporateActionsScreen extends ConsumerStatefulWidget {
  const CorporateActionsScreen({super.key});

  @override
  ConsumerState<CorporateActionsScreen> createState() =>
      _CorporateActionsScreenState();
}

class _CorporateActionsScreenState
    extends ConsumerState<CorporateActionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const _tabs = [
    'Dividend',
    'Bonus',
    'Split',
    'Rights',
    'Buyback',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ACTIONS'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: _tabs.map((t) => Tab(text: t.toUpperCase())).toList(),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _tabs.map((type) => _ActionTab(actionType: type)).toList(),
      ),
    );
  }
}

class _ActionTab extends ConsumerWidget {
  final String actionType;

  const _ActionTab({required this.actionType});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(filteredCorporateActionsProvider(actionType));

    return FadeSwitcher(
      child: asyncData.when(
        loading: () => Padding(
          key: const ValueKey('loading'),
          padding: AppSpacing.screenPadding,
          child: const SkeletonLoader(itemCount: 5, itemHeight: 68),
        ),
        error: (err, _) => ErrorState(
          key: const ValueKey('error'),
          message: 'Failed to load $actionType data.',
          onRetry: () => ref.invalidate(corporateActionsProvider),
        ),
        data: (items) {
          if (items.isEmpty) {
            return EmptyState(
              key: const ValueKey('empty'),
              icon: Icons.event_note_outlined,
              message: 'No $actionType actions.',
            );
          }

          return ListView.builder(
            key: const ValueKey('data'),
            padding: AppSpacing.screenPadding,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final action = items[index];

              return Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                padding: AppSpacing.cardPadding,
                decoration: BoxDecoration(
                  color: AppColors.surface1,
                  borderRadius:
                      BorderRadius.circular(AppSpacing.cardRadius),
                  border:
                      Border.all(color: AppColors.border, width: 1),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            action.shortName,
                            style: AppTypography.bodyMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            action.purpose,
                            style: AppTypography.bodySecondary
                                .copyWith(fontSize: 13),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Row(
                            children: [
                              Text(
                                'Ex: ${action.exDate ?? 'TBA'}',
                                style: AppTypography.timestamp,
                              ),
                              if (action.dividendAmount != null) ...[
                                const SizedBox(width: AppSpacing.sm),
                                Text(
                                  '₹${action.dividendAmount!.toStringAsFixed(2)}',
                                  style: AppTypography.metadata.copyWith(
                                    color: AppColors.success,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Right: action type badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm - 2,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface2,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.badgeRadius),
                      ),
                      child: Text(
                        action.actionType.toUpperCase(),
                        style: AppTypography.timestamp.copyWith(
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
