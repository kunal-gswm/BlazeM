import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../data/repositories/providers.dart';
import '../../data/models/fii_dii_model.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_state.dart';

class FiiDiiScreen extends ConsumerStatefulWidget {
  const FiiDiiScreen({super.key});

  @override
  ConsumerState<FiiDiiScreen> createState() => _FiiDiiScreenState();
}

class _FiiDiiScreenState extends ConsumerState<FiiDiiScreen> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final asyncData = ref.watch(fiiDiiDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('INSTITUTIONAL FLOWS'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(fiiDiiDataProvider),
          ),
        ],
      ),
      body: asyncData.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorState(
          message: 'Failed to load flows',
          onRetry: () => ref.invalidate(fiiDiiDataProvider),
        ),
        data: (response) {
          final data = response.data;
          if (data.isEmpty) {
            return const EmptyState(
              icon: Icons.bar_chart_rounded,
              message: 'No Data Available',
              submessage: 'Flow data will appear when markets are open.',
            );
          }

          // Group by date
          final Map<String, Map<String, FiiDiiModel>> grouped = {};
          for (var item in data) {
            grouped.putIfAbsent(item.date, () => {});
            grouped[item.date]![item.category] = item;
          }

          // Sort dates ascending for the chart (oldest to newest)
          final sortedDates = grouped.keys.toList()
            ..sort((a, b) {
              try {
                final da = DateFormat('dd-MMM-yyyy').parse(a);
                final db = DateFormat('dd-MMM-yyyy').parse(b);
                return da.compareTo(db);
              } catch (_) {
                return 0;
              }
            });

          // Take last 90 days for the chart
          final chartDates = sortedDates.length > 90 
              ? sortedDates.sublist(sortedDates.length - 90) 
              : sortedDates;

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(fiiDiiDataProvider),
            child: ListView(
              padding: AppSpacing.screenPadding,
              children: [
                _buildSummaryCards(grouped, sortedDates.last),
                const SizedBox(height: AppSpacing.xl),
                Text('NET FLOW TREND (LAST ${chartDates.length} DAYS)', style: AppTypography.label),
                const SizedBox(height: AppSpacing.md),
                _buildChart(grouped, chartDates, context),
                const SizedBox(height: AppSpacing.xl),
                _buildMonthlyAnalytics(grouped, sortedDates),
                const SizedBox(height: AppSpacing.xl),
                Text('RECENT HISTORY', style: AppTypography.label),
                const SizedBox(height: AppSpacing.md),
                ...sortedDates.reversed.take(30).map((date) => _buildHistoryRow(date, grouped[date]!)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCards(Map<String, Map<String, FiiDiiModel>> grouped, String latestDate) {
    final todayData = grouped[latestDate]!;
    final fii = todayData.values.firstWhere((e) => e.category.contains('FII'), orElse: () => FiiDiiModel(category: 'FII', date: latestDate, netValue: 0));
    final dii = todayData.values.firstWhere((e) => e.category.contains('DII'), orElse: () => FiiDiiModel(category: 'DII', date: latestDate, netValue: 0));
    
    return Row(
      children: [
        Expanded(child: _StatCard(title: 'FII NET', value: fii.netValue ?? 0, date: latestDate)),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: _StatCard(title: 'DII NET', value: dii.netValue ?? 0, date: latestDate)),
      ],
    );
  }

  Widget _buildChart(Map<String, Map<String, FiiDiiModel>> grouped, List<String> dates, BuildContext context) {
    final double maxAbsValue = _calculateMaxAbsoluteValue(grouped, dates);
    final double maxY = maxAbsValue > 0 ? (maxAbsValue * 1.2).ceilToDouble() : 1000;
    
    // Dynamic width calculation based on the number of dates.
    // Minimum 300px or full screen width, but extends up to 40px per date.
    final screenWidth = MediaQuery.of(context).size.width - 32; // minus padding
    final double chartWidth = dates.length * 40.0;
    final double finalWidth = chartWidth > screenWidth ? chartWidth : screenWidth;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        height: 250,
        width: finalWidth,
        padding: const EdgeInsets.only(top: 24, right: 16, left: 0, bottom: 0),
        decoration: BoxDecoration(
          color: AppColors.surface1,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(color: AppColors.border),
        ),
        child: BarChart(
          BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          minY: -maxY,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final date = dates[group.x];
                final category = rodIndex == 0 ? 'FII' : 'DII';
                return BarTooltipItem(
                  '$date\n$category: ₹${rod.toY.toStringAsFixed(2)} Cr',
                  AppTypography.metadata.copyWith(color: Colors.white),
                );
              },
            ),
            touchCallback: (FlTouchEvent event, barTouchResponse) {
              setState(() {
                if (!event.isInterestedForInteractions || barTouchResponse == null || barTouchResponse.spot == null) {
                  _touchedIndex = -1;
                  return;
                }
                _touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
              });
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  if (value.toInt() >= dates.length) return const SizedBox.shrink();
                  // Only show 4-5 labels to avoid crowding
                  if (dates.length > 7 && value.toInt() % 3 != 0) return const SizedBox.shrink();
                  final date = dates[value.toInt()];
                  try {
                    final d = DateFormat('dd-MMM-yyyy').parse(date);
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(DateFormat('dd MMM').format(d), style: AppTypography.metadata.copyWith(fontSize: 9)),
                    );
                  } catch (_) {
                    return const SizedBox.shrink();
                  }
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  if (value == maxY || value == -maxY) return const SizedBox.shrink();
                  return Text(
                    '${(value / 1000).toStringAsFixed(1)}k',
                    style: AppTypography.metadata.copyWith(fontSize: 10),
                    textAlign: TextAlign.right,
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY / 2,
            getDrawingHorizontalLine: (value) => FlLine(
              color: AppColors.border,
              strokeWidth: 1,
              dashArray: value == 0 ? null : [4, 4],
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(dates.length, (index) {
            final date = dates[index];
            final dayData = grouped[date]!;
            final fii = dayData.values.firstWhere((e) => e.category.contains('FII'), orElse: () => FiiDiiModel(category: 'FII', date: date, netValue: 0));
            final dii = dayData.values.firstWhere((e) => e.category.contains('DII'), orElse: () => FiiDiiModel(category: 'DII', date: date, netValue: 0));
            
            final isTouched = index == _touchedIndex;
            
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: fii.netValue ?? 0,
                  color: (fii.netValue ?? 0) >= 0 ? AppColors.success : AppColors.danger,
                  width: 8,
                  borderRadius: BorderRadius.circular(2),
                  backDrawRodData: BackgroundBarChartRodData(show: isTouched, toY: maxY, color: AppColors.surface2),
                ),
                BarChartRodData(
                  toY: dii.netValue ?? 0,
                  color: (dii.netValue ?? 0) >= 0 ? AppColors.success.withValues(alpha: 0.5) : AppColors.danger.withValues(alpha: 0.5),
                  width: 8,
                  borderRadius: BorderRadius.circular(2),
                  backDrawRodData: BackgroundBarChartRodData(show: isTouched, toY: maxY, color: AppColors.surface2),
                ),
              ],
            );
          }),
        ),
      ),
      ),
    );
  }

  Widget _buildMonthlyAnalytics(Map<String, Map<String, FiiDiiModel>> grouped, List<String> sortedDates) {
    // Group dates by Month (e.g., "Jun 2026")
    final Map<String, Map<String, double>> monthlyTotals = {};
    
    for (final date in sortedDates) {
      try {
        final d = DateFormat('dd-MMM-yyyy').parse(date);
        final monthKey = DateFormat('MMM yyyy').format(d);
        
        monthlyTotals.putIfAbsent(monthKey, () => {'FII': 0.0, 'DII': 0.0});
        
        final dayData = grouped[date]!;
        final fii = dayData.values.firstWhere((e) => e.category.contains('FII'), orElse: () => FiiDiiModel(category: 'FII', date: date, netValue: 0));
        final dii = dayData.values.firstWhere((e) => e.category.contains('DII'), orElse: () => FiiDiiModel(category: 'DII', date: date, netValue: 0));
        
        monthlyTotals[monthKey]!['FII'] = monthlyTotals[monthKey]!['FII']! + (fii.netValue ?? 0);
        monthlyTotals[monthKey]!['DII'] = monthlyTotals[monthKey]!['DII']! + (dii.netValue ?? 0);
      } catch (_) {}
    }

    final sortedMonths = monthlyTotals.keys.toList(); // since we iterated older to newer initially, but wait, sortedDates is oldest first.
    // We want newest month first
    final reversedMonths = sortedMonths.reversed.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('MONTHLY BEHAVIOR', style: AppTypography.label),
        const SizedBox(height: AppSpacing.md),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: reversedMonths.map((month) {
              final totals = monthlyTotals[month]!;
              return _MonthlyInsightCard(month: month, fiiTotal: totals['FII']!, diiTotal: totals['DII']!);
            }).toList(),
          ),
        ),
      ],
    );
  }

  double _calculateMaxAbsoluteValue(Map<String, Map<String, FiiDiiModel>> grouped, List<String> dates) {
    double maxVal = 0;
    for (var date in dates) {
      for (var item in grouped[date]!.values) {
        if (item.netValue != null) {
          final absVal = item.netValue!.abs();
          if (absVal > maxVal) maxVal = absVal;
        }
      }
    }
    return maxVal;
  }

  Widget _buildHistoryRow(String date, Map<String, FiiDiiModel> data) {
    final fii = data.values.firstWhere((e) => e.category.contains('FII'), orElse: () => FiiDiiModel(category: 'FII', date: date));
    final dii = data.values.firstWhere((e) => e.category.contains('DII'), orElse: () => FiiDiiModel(category: 'DII', date: date));
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface1,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(date, style: AppTypography.label),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _HistoryCell(title: 'FII NET', value: fii.netValue),
              _HistoryCell(title: 'DII NET', value: dii.netValue),
              _HistoryCell(title: 'TOTAL', value: (fii.netValue ?? 0) + (dii.netValue ?? 0)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final double value;
  final String date;

  const _StatCard({required this.title, required this.value, required this.date});

  @override
  Widget build(BuildContext context) {
    final isPositive = value >= 0;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isPositive ? AppColors.success.withValues(alpha: 0.1) : AppColors.danger.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: isPositive ? AppColors.success.withValues(alpha: 0.3) : AppColors.danger.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.metadata),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '₹${value.toStringAsFixed(2)} Cr',
            style: AppTypography.value.copyWith(
              color: isPositive ? AppColors.success : AppColors.danger,
            ),
          ),
          const SizedBox(height: 2),
          Text('As of $date', style: AppTypography.metadata.copyWith(fontSize: 9)),
        ],
      ),
    );
  }
}

class _HistoryCell extends StatelessWidget {
  final String title;
  final double? value;

  const _HistoryCell({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    final isPositive = (value ?? 0) >= 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.metadata),
        const SizedBox(height: 2),
        Text(
          value != null ? '₹${value!.toStringAsFixed(2)}' : '-',
          style: AppTypography.bodyMedium.copyWith(
            color: value != null ? (isPositive ? AppColors.success : AppColors.danger) : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _MonthlyInsightCard extends StatelessWidget {
  final String month;
  final double fiiTotal;
  final double diiTotal;

  const _MonthlyInsightCard({required this.month, required this.fiiTotal, required this.diiTotal});

  @override
  Widget build(BuildContext context) {
    final netTotal = fiiTotal + diiTotal;
    final isPositive = netTotal >= 0;

    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface1,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(month.toUpperCase(), style: AppTypography.label.copyWith(color: AppColors.textPrimary)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isPositive ? AppColors.success.withValues(alpha: 0.1) : AppColors.danger.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isPositive ? 'INFLOW' : 'OUTFLOW',
                  style: AppTypography.metadata.copyWith(
                    color: isPositive ? AppColors.success : AppColors.danger,
                    fontWeight: FontWeight.bold,
                    fontSize: 9,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          _HistoryCell(title: 'FII NET', value: fiiTotal),
          const SizedBox(height: 4),
          _HistoryCell(title: 'DII NET', value: diiTotal),
          const Divider(color: AppColors.border, height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('TOTAL', style: AppTypography.metadata),
              Text(
                '${isPositive ? '+' : ''}₹${netTotal.toStringAsFixed(0)} Cr',
                style: AppTypography.value.copyWith(
                  color: isPositive ? AppColors.success : AppColors.danger,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
