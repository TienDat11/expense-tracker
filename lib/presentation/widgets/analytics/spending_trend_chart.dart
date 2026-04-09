import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/data/models/transaction_model.dart';
import 'package:expense_tracker/data/models/transaction_type.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Line chart displaying daily spending/income trend for current month.
///
/// Shows transaction amounts grouped by day.
/// X-axis: Day of month
/// Y-axis: Amount in VND
/// Uses smooth curve with subtle grid lines.
class SpendingTrendChart extends StatelessWidget {
  final List<TransactionModel> transactions;
  final TransactionType type;

  const SpendingTrendChart({
    super.key,
    required this.transactions,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final dailyTotals = _calculateDailyTotals();

    if (dailyTotals.isEmpty) {
      return _buildEmptyState();
    }

    final spots = dailyTotals.entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
        .toList()
      ..sort((a, b) => a.x.compareTo(b.x));

    final maxValue =
        dailyTotals.values.reduce((a, b) => a > b ? a : b);

    return RepaintBoundary(
      child: AspectRatio(
        aspectRatio: 1.7,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: _calculateYAxisInterval(maxValue),
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: AppColors.outline.withValues(alpha: 0.2),
                  strokeWidth: 1,
                );
              },
            ),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 22,
                  interval: 5,
                  getTitlesWidget: (value, meta) {
                    if (value % 5 != 0 && value != meta.max) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 50,
                  interval: _calculateYAxisInterval(maxValue),
                  getTitlesWidget: (value, meta) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(
                        CurrencyFormatter.format(value),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(
                color: AppColors.outline.withValues(alpha: 0.3),
              ),
            ),
            minX: 1,
            maxX: 31,
            minY: 0,
            maxY: maxValue * 1.1,
            lineBarsData: [
              LineChartBarData(
                isCurved: true,
                color: type == TransactionType.income
                    ? AppColors.success
                    : AppColors.error,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: true),
                belowBarData: BarAreaData(
                  show: true,
                  color: type == TransactionType.income
                      ? AppColors.success.withValues(alpha: 0.1)
                      : AppColors.error.withValues(alpha: 0.1),
                ),
                spots: spots,
              ),
            ],
            lineTouchData: const LineTouchData(enabled: false),
          ),
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        ),
      ),
    );
  }

  /// Groups transactions by day of month and calculates totals.
  Map<int, double> _calculateDailyTotals() {
    final now = DateTime.now();
    final currentMonth = now.month;
    final currentYear = now.year;

    final dailyTotals = <int, double>{};

    for (final transaction in transactions) {
      if (transaction.type != type) {
        continue;
      }

      if (transaction.transactionDate.month != currentMonth ||
          transaction.transactionDate.year != currentYear) {
        continue;
      }

      final day = transaction.transactionDate.day;
      dailyTotals[day] =
          (dailyTotals[day] ?? 0) + transaction.amount;
    }

    return dailyTotals;
  }

  /// Calculates appropriate Y-axis interval based on max value.
  double _calculateYAxisInterval(double maxValue) {
    if (maxValue <= 100000) {
      return 20000;
    } else if (maxValue <= 500000) {
      return 100000;
    } else if (maxValue <= 1000000) {
      return 200000;
    } else if (maxValue <= 5000000) {
      return 1000000;
    } else {
      return 2000000;
    }
  }

  /// Builds empty state when no trend data available.
  Widget _buildEmptyState() {
    return Container(
      height: 200,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.show_chart,
            size: 48,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          const Text(
            'Chưa có dữ liệu xu hướng',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
