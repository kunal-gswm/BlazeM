import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../data/repositories/providers.dart';

class FearAndGreedGaugeWidget extends ConsumerWidget {
  const FearAndGreedGaugeWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(marketSentimentProvider);

    return asyncData.when(
      loading: () => const SizedBox.shrink(),
      error: (err, stack) => const SizedBox.shrink(),
      data: (response) {
        if (response.data.isEmpty) return const SizedBox.shrink();
        final sentiment = response.data.first;
        
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface1,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Text('Market Sentiment', style: AppTypography.sectionTitle),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                height: 120,
                width: 240,
                child: CustomPaint(
                  painter: _GaugePainter(score: sentiment.score.toDouble()),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                sentiment.label.toUpperCase(),
                style: AppTypography.value.copyWith(
                  fontSize: 20,
                  color: _getColorForScore(sentiment.score.toDouble()),
                ),
              ),
              Text(
                'Score: ${sentiment.score}',
                style: AppTypography.bodySecondary,
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getColorForScore(double score) {
    if (score < 30) return Colors.red;
    if (score < 50) return Colors.orange;
    if (score < 70) return Colors.lightGreen;
    return Colors.green;
  }
}

class _GaugePainter extends CustomPainter {
  final double score;

  _GaugePainter({required this.score});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2;

    final bgPaint = Paint()
      ..color = AppColors.surface2
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(center: center, radius: radius - 10);
    canvas.drawArc(rect, math.pi, math.pi, false, bgPaint);

    _drawSegment(canvas, rect, math.pi, math.pi * 0.3, Colors.red);
    _drawSegment(canvas, rect, math.pi * 1.3, math.pi * 0.2, Colors.orange);
    _drawSegment(canvas, rect, math.pi * 1.5, math.pi * 0.2, Colors.lightGreen);
    _drawSegment(canvas, rect, math.pi * 1.7, math.pi * 0.3, Colors.green);

    final needleAngle = math.pi + (score / 100) * math.pi;
    final needlePaint = Paint()
      ..color = AppColors.textPrimary
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final needleLength = radius - 30;
    final needleEnd = Offset(
      center.dx + needleLength * math.cos(needleAngle),
      center.dy + needleLength * math.sin(needleAngle),
    );

    canvas.drawLine(center, needleEnd, needlePaint);
    canvas.drawCircle(center, 8, Paint()..color = AppColors.textPrimary);
  }

  void _drawSegment(Canvas canvas, Rect rect, double startAngle, double sweepAngle, Color color) {
    final paint = Paint()
      ..color = color.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.butt;
    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(_GaugePainter oldDelegate) => oldDelegate.score != score;
}
