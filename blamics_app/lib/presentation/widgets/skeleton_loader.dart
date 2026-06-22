import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

/// Shimmer-based skeleton loader that replaces CircularProgressIndicator.
class SkeletonLoader extends StatefulWidget {
  final int itemCount;
  final double itemHeight;

  const SkeletonLoader({
    super.key,
    this.itemCount = 4,
    this.itemHeight = 72,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _animation = Tween<double>(begin: 0.3, end: 0.6).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.itemCount,
          padding: EdgeInsets.zero,
          itemBuilder: (context, index) {
            return _SkeletonCard(
              opacity: _animation.value,
              height: widget.itemHeight,
            );
          },
        );
      },
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  final double opacity;
  final double height;

  const _SkeletonCard({
    required this.opacity,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface1.withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(
          color: AppColors.border.withValues(alpha: opacity * 0.5),
          width: 1,
        ),
      ),
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _SkeletonLine(width: 0.6, opacity: opacity),
            const SizedBox(height: AppSpacing.sm),
            _SkeletonLine(width: 0.4, opacity: opacity),
            const SizedBox(height: AppSpacing.sm),
            _SkeletonLine(width: 0.25, opacity: opacity),
          ],
        ),
      ),
    );
  }
}

class _SkeletonLine extends StatelessWidget {
  final double width;
  final double opacity;

  const _SkeletonLine({
    required this.width,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: width,
      child: Container(
        height: 10,
        decoration: BoxDecoration(
          color: AppColors.surface2.withValues(alpha: opacity),
          borderRadius: BorderRadius.circular(AppSpacing.badgeRadius),
        ),
      ),
    );
  }
}
