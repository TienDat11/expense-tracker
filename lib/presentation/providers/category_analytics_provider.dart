import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/data/models/category_model.dart';
import 'package:expense_tracker/data/models/category_stats_model.dart';
import 'package:expense_tracker/data/models/transaction_model.dart';
import 'package:expense_tracker/data/models/transaction_type.dart';
import 'package:expense_tracker/presentation/providers/category_provider.dart';
import 'package:expense_tracker/presentation/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Analytics type for category breakdown.
enum AnalyticsType { expense, income }

/// Provider family for category analytics by type.
///
/// Computes spending or income breakdown by category
/// for the current month. Returns top 6 categories
/// with remaining grouped as "Khác".
final categoryAnalyticsProvider =
    Provider.family<List<CategoryStatsModel>, AnalyticsType>((ref, type) {
  final transactions = ref.watch(transactionProvider).valueOrNull ?? [];
  final categories = ref.watch(categoryProvider).valueOrNull ?? [];

  return _computeCategoryStats(
    transactions: transactions,
    categories: categories,
    type: type,
  );
});

/// Computes category statistics from transactions and categories.
///
/// Filters by current month and transaction type,
/// groups by category, aggregates totals, calculates
/// percentages, and limits to top 6 items.
List<CategoryStatsModel> _computeCategoryStats({
  required List<TransactionModel> transactions,
  required List<CategoryModel> categories,
  required AnalyticsType type,
}) {
  final now = DateTime.now();
  final currentMonthStart = DateTime(now.year, now.month, 1);
  final nextMonthStart = DateTime(now.year, now.month + 1, 1);

  // Filter transactions by month and type
  final typeEnum =
      type == AnalyticsType.income
          ? TransactionType.income
          : TransactionType.expense;

  final filteredTransactions = transactions.where((t) {
    final inMonth = t.transactionDate.isAtSameMomentAs(currentMonthStart) ||
        (t.transactionDate.isAfter(currentMonthStart) &&
            t.transactionDate.isBefore(nextMonthStart));
    final correctType = t.type == typeEnum;
    return inMonth && correctType;
  }).toList();

  // Return empty if no transactions
  if (filteredTransactions.isEmpty) {
    return [];
  }

  // Create category lookup map
  final categoryMap = <String, CategoryModel>{};
  for (final category in categories) {
    categoryMap[category.id] = category;
  }

  // Aggregate transactions by category
  final categoryTotals = <String, double>{};
  final categoryCounts = <String, int>{};

  for (final transaction in filteredTransactions) {
    final categoryId = transaction.categoryId;
    categoryTotals[categoryId] =
        (categoryTotals[categoryId] ?? 0) + transaction.amount;
    categoryCounts[categoryId] = (categoryCounts[categoryId] ?? 0) + 1;
  }

  // Calculate grand total for percentages
  final grandTotal =
      categoryTotals.values.fold<double>(0, (sum, amount) => sum + amount);

  // Return empty if total is zero
  if (grandTotal == 0) {
    return [];
  }

  // Build stats list
  final stats = <CategoryStatsModel>[];

  for (final entry in categoryTotals.entries) {
    final categoryId = entry.key;
    final category = categoryMap[categoryId];

    // Skip if category is missing (deleted)
    if (category == null) {
      continue;
    }

    final totalAmount = entry.value;
    final transactionCount = categoryCounts[categoryId] ?? 0;
    final percentage = grandTotal > 0 ? (totalAmount / grandTotal) * 100 : 0.0;

    stats.add(CategoryStatsModel(
      categoryId: categoryId,
      categoryName: category.name,
      categoryColor: Color(
        int.parse(category.color.replaceFirst('#', 'FF'), radix: 16),
      ),
      categoryIcon: _getIconData(category.icon),
      totalAmount: totalAmount,
      transactionCount: transactionCount,
      percentage: percentage,
    ));
  }

  // Sort by total amount descending
  stats.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));

  // Limit to top 6, group rest as "Khác"
  final top6 = stats.take(6).toList();
  final remaining = stats.skip(6).toList();

  if (remaining.isNotEmpty) {
    final otherTotal = remaining.fold<double>(
      0.0,
      (sum, stat) => sum + stat.totalAmount,
    );
    final otherCount = remaining.fold<int>(
      0,
      (sum, stat) => sum + stat.transactionCount,
    );
    final otherPercentage = grandTotal > 0 ? (otherTotal / grandTotal) * 100 : 0.0;

    top6.add(CategoryStatsModel(
      categoryId: 'other',
      categoryName: 'Khác',
      categoryColor: AppColors.primary.withValues(alpha: 0.7),
      categoryIcon: Icons.more_horiz,
      totalAmount: otherTotal,
      transactionCount: otherCount,
      percentage: otherPercentage,
    ));
  }

  return top6;
}

/// Converts icon name string to IconData.
///
/// Handles Material Design icons by name.
/// Returns Icons.help_outline for unknown icons.
IconData _getIconData(String iconName) {
  try {
    return IconData(
      int.parse(iconName.replaceAll('Icons.', ''), radix: 16),
      fontFamily: 'MaterialIcons',
    );
  } catch (_) {
    return Icons.help_outline;
  }
}
