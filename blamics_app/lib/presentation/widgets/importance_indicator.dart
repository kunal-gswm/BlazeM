import 'package:flutter/material.dart';
import '../../core/constants/app_enums.dart';
import '../../core/theme/app_spacing.dart';

class ImportanceIndicator extends StatelessWidget {
  final ImportanceLevel level;
  final double height;

  const ImportanceIndicator({
    super.key,
    required this.level,
    this.height = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 4,
      height: height,
      decoration: BoxDecoration(
        color: level.color,
        borderRadius: BorderRadius.circular(AppSpacing.badgeRadius),
      ),
    );
  }
}
