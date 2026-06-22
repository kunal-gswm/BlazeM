import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

class FilterChipBar extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const FilterChipBar({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: labels.length,
        separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;
          return GestureDetector(
            onTap: () => onSelected(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : AppColors.surface2,
                borderRadius: BorderRadius.circular(AppSpacing.badgeRadius),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: 1,
                ),
              ),
              child: Text(
                labels[index],
                style: AppTypography.metadata.copyWith(
                  color:
                      isSelected ? AppColors.primary : AppColors.textSecondary,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
