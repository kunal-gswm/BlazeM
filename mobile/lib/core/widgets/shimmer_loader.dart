import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_colors.dart';

/// Shimmer loading skeleton.
///
/// Mirrors the expected layout shape. No spinners. No progress bars.
class ShimmerLoader extends StatelessWidget {
  const ShimmerLoader({
    super.key,
    required this.child,
  });

  /// The skeleton layout to shimmer. Use Container with fixed
  /// dimensions to match the expected content shape.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.cardDark,
      highlightColor: AppColors.cardElevatedDark,
      child: child,
    );
  }

  /// Convenience: a single rectangular shimmer block.
  static Widget block({
    double width = double.infinity,
    double height = 16,
    double borderRadius = 4,
  }) {
    return ShimmerLoader(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }

  /// Convenience: a shimmer list of N items.
  static Widget list({
    int itemCount = 5,
    double itemHeight = 64,
    double spacing = 8,
  }) {
    return Column(
      children: List.generate(itemCount, (i) {
        return Padding(
          padding: EdgeInsets.only(bottom: i < itemCount - 1 ? spacing : 0),
          child: ShimmerLoader(
            child: Container(
              height: itemHeight,
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        );
      }),
    );
  }
}
