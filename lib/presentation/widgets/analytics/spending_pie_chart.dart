import 'package:expense_tracker/data/models/category_stats_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Donut/pie chart displaying category breakdown.
///
/// Shows top 6 categories with remaining grouped as "Khác".
/// Uses fl_chart PieChart with hollow center for donut style.
/// Maximum 6 slices for readability.
class SpendingPieChart extends StatelessWidget {
  final List<dynamic> categoryStats;

  const SpendingPieChart({
    super.key,
    required this.categoryStats,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (categoryStats.isEmpty) {
      return const SizedBox.shrink();
    }

    final List<PieChartSectionData> pieChartData = categoryStats.map((stat) {
      final categoryStat = stat as CategoryStatsModel;
      return PieChartSectionData(
        color: categoryStat.categoryColor,
        value: categoryStat.totalAmount,
        title: '',
        radius: 60,
        titleStyle: const TextStyle(fontSize: 0),
      );
    }).toList();

    return AspectRatio(
      aspectRatio: 1.3,
      child: RepaintBoundary(
        child: PieChart(
          PieChartData(
            sectionsSpace: 2,
            centerSpaceRadius: 60,
            centerSpaceColor: theme.colorScheme.surface,
            sections: pieChartData,
            pieTouchData: PieTouchData(enabled: false),
          ),
          swapAnimationDuration: const Duration(milliseconds: 250),
          swapAnimationCurve: Curves.easeOut,
        ),
      ),
    );
  }
}
