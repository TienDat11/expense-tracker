import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/data/models/category_stats_model.dart';
import 'package:flutter/material.dart';

/// Horizontal bar chart displaying category breakdown.
///
/// Shows spending by category with horizontal bars for comparison.
/// Matches "Chi tiết theo danh mục" section semantics.
/// Handles empty states and various data ranges gracefully.
class CategoryBarChart extends StatelessWidget {
  final List<dynamic> categoryStats;

  const CategoryBarChart({
    super.key,
    required this.categoryStats,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (categoryStats.isEmpty) {
      return _buildEmptyState(context);
    }

    final stats = categoryStats.cast<CategoryStatsModel>();
    final maxAmount = stats
        .map((s) => s.totalAmount)
        .reduce((a, b) => a > b ? a : b);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: theme.colorScheme.outline, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Biểu đồ theo danh mục',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ...stats.asMap().entries.map((entry) {
              final index = entry.key;
              final stat = entry.value;
              return _buildBar(
                stat: stat,
                maxAmount: maxAmount,
                isLast: index == stats.length - 1,
                theme: theme,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildBar({
    required CategoryStatsModel stat,
    required double maxAmount,
    required bool isLast,
    required ThemeData theme,
  }) {
    final barColor = stat.categoryId == 'other'
        ? AppColors.primary
        : stat.categoryColor;
    final barWidth = maxAmount > 0 ? (stat.totalAmount / maxAmount) : 0;

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  stat.categoryName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    CurrencyFormatter.format(stat.totalAmount),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: barColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: barWidth.clamp(0.0, 1.0).toDouble(),
              backgroundColor: AppColors.outline.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                barColor.withValues(alpha: 0.7),
              ),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline, width: 1),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart,
            size: 40,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 8),
          const Text(
            'Chưa có dữ liệu',
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
