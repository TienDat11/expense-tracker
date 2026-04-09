import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/data/models/category_stats_model.dart';
import 'package:flutter/material.dart';

/// Scrollable list displaying category breakdown statistics.
///
/// Shows category icon, name, percentage, and amount.
/// Matches order of donut chart for visual consistency.
class CategoryBreakdownList extends StatelessWidget {
  final List<dynamic> categoryStats;

  const CategoryBreakdownList({
    super.key,
    required this.categoryStats,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (categoryStats.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: theme.colorScheme.outline, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              'Chi tiết theo danh mục',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Divider(
            height: 1,
            color: theme.colorScheme.outline,
          ),
          // List items
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: categoryStats.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              indent: 56,
              color: AppColors.outline.withValues(alpha: 0.2),
            ),
            itemBuilder: (context, index) {
              final stat = categoryStats[index] as CategoryStatsModel;
              return _buildCategoryItem(stat, theme);
            },
          ),
        ],
      ),
    );
  }

  /// Builds individual category list item.
  Widget _buildCategoryItem(
    CategoryStatsModel stat,
    ThemeData theme,
  ) {
    final iconBackground = theme.colorScheme.surfaceContainer;
    final amountColor = stat.categoryId == 'other'
        ? AppColors.primary
        : stat.categoryColor;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconBackground,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          stat.categoryIcon,
          color: stat.categoryColor,
          size: 22,
        ),
      ),
      title: Text(
        stat.categoryName,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        '${stat.transactionCount} giao dịch',
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
      ),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            CurrencyFormatter.format(stat.totalAmount),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: amountColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${stat.percentage.toStringAsFixed(1)}%',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
