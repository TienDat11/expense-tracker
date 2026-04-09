import 'package:expense_tracker/data/models/category_model.dart';
import 'package:expense_tracker/data/models/transaction_model.dart';
import 'package:expense_tracker/data/models/transaction_type.dart';
import 'package:expense_tracker/domain/models/analytics_insight_model.dart';
import 'package:expense_tracker/presentation/providers/category_provider.dart';
import 'package:expense_tracker/presentation/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Vietnamese month names (1-indexed: January = 1)
const _vietnameseMonthNames = [
  '', // placeholder for 0
  'Tháng 1',
  'Tháng 2',
  'Tháng 3',
  'Tháng 4',
  'Tháng 5',
  'Tháng 6',
  'Tháng 7',
  'Tháng 8',
  'Tháng 9',
  'Tháng 10',
  'Tháng 11',
  'Tháng 12',
];

/// Returns Vietnamese month name from DateTime.
///
/// Locale-independent helper that doesn't require initializeDateFormatting().
String _getVietnameseMonthName(DateTime date) {
  return _vietnameseMonthNames[date.month];
}

/// Provider for analytics insights.
///
/// Generates rule-based insights from transaction data.
/// Returns up to 3 insights in priority order.
final analyticsInsightProvider = Provider<List<AnalyticsInsightModel>>((ref) {
  final transactions = ref.watch(transactionProvider).valueOrNull ?? [];
  final categories = ref.watch(categoryProvider).valueOrNull ?? [];
  return _computeInsights(transactions, categories);
});

/// Computes analytics insights from transactions and categories.
///
/// Analyzes spending patterns and generates up to 3 insights:
/// 1. Spending comparison (current vs previous month)
/// 2. Top spending category
/// 3. Highest spending day of week
List<AnalyticsInsightModel> _computeInsights(
  List<TransactionModel> transactions,
  List<CategoryModel> categories,
) {
  final insights = <AnalyticsInsightModel>[];

  // Return no data insight if no transactions exist
  if (transactions.isEmpty) {
    return [
      const AnalyticsInsightModel(
        type: InsightType.noData,
        title: 'Chưa có dữ liệu',
        description: 'Thêm giao dịch để nhận được gợi ý chi tiêu',
      ),
    ];
  }

  // Create category lookup map
  final categoryMap = <String, CategoryModel>{};
  for (final category in categories) {
    categoryMap[category.id] = category;
  }

  // Insight 1: Spending comparison (current vs previous month)
  final comparisonInsight = _computeSpendingComparison(
    transactions,
    categoryMap,
  );
  if (comparisonInsight != null) {
    insights.add(comparisonInsight);
  }

  // Insight 2: Top spending category
  final topCategoryInsight = _computeTopCategory(
    transactions,
    categoryMap,
  );
  if (topCategoryInsight != null) {
    insights.add(topCategoryInsight);
  }

  // Insight 3: Highest spending day of week
  final dayInsight = _computeHighestSpendingDay(transactions);
  if (dayInsight != null) {
    insights.add(dayInsight);
  }

  // Limit to 3 insights
  return insights.take(3).toList();
}

/// Computes spending comparison between current and previous month.
///
/// Returns an insight if spending increased or decreased significantly.
AnalyticsInsightModel? _computeSpendingComparison(
  List<TransactionModel> transactions,
  Map<String, CategoryModel> categoryMap,
) {
  final now = DateTime.now();
  final currentMonthStart = DateTime(now.year, now.month, 1);
  final currentMonthEnd = DateTime(now.year, now.month + 1, 1);
  final previousMonthStart = DateTime(now.year, now.month - 1, 1);

  // Calculate current month spending
  double currentSpending = 0;
  for (final t in transactions) {
    if (t.type == TransactionType.expense &&
        t.transactionDate.isAtSameMomentAs(currentMonthStart) ||
        (t.transactionDate.isAfter(currentMonthStart) &&
            t.transactionDate.isBefore(currentMonthEnd))) {
      currentSpending += t.amount;
    }
  }

  // Calculate previous month spending
  double previousSpending = 0;
  for (final t in transactions) {
    if (t.type == TransactionType.expense &&
        t.transactionDate.isAtSameMomentAs(previousMonthStart) ||
        (t.transactionDate.isAfter(previousMonthStart) &&
            t.transactionDate.isBefore(currentMonthStart))) {
      previousSpending += t.amount;
    }
  }

  // No previous month data
  if (previousSpending == 0) {
    return null;
  }

  // Calculate percentage change
  final change = ((currentSpending - previousSpending) / previousSpending) * 100;
  final absoluteChange = change.abs();

  // Only show insight if change is at least 10%
  if (absoluteChange < 10) {
    return null;
  }

  final direction = change > 0 ? ChangeDirection.increase : ChangeDirection.decrease;
  final monthName = _getVietnameseMonthName(now);
  final prevMonthName = _getVietnameseMonthName(previousMonthStart);

  final title = change > 0
      ? 'Chi tiêu tăng $monthName'
      : 'Chi tiêu giảm $monthName';

  final description = change > 0
      ? 'Bạn đã chi tiêu ${absoluteChange.toInt()}% nhiều hơn so với $prevMonthName'
      : 'Bạn đã chi tiêu ${absoluteChange.toInt()}% ít hơn so với $prevMonthName';

  return AnalyticsInsightModel(
    type: change > 0 ? InsightType.spendingIncrease : InsightType.spendingDecrease,
    title: title,
    description: description,
    percentageChange: absoluteChange,
    changeDirection: direction,
  );
}

/// Computes top spending category insight.
///
/// Returns the category with highest spending in current month.
AnalyticsInsightModel? _computeTopCategory(
  List<TransactionModel> transactions,
  Map<String, CategoryModel> categoryMap,
) {
  final now = DateTime.now();
  final currentMonthStart = DateTime(now.year, now.month, 1);
  final currentMonthEnd = DateTime(now.year, now.month + 1, 1);

  // Filter expense transactions for current month
  final categoryTotals = <String, double>{};
  for (final t in transactions) {
    if (t.type == TransactionType.expense &&
        (t.transactionDate.isAtSameMomentAs(currentMonthStart) ||
            (t.transactionDate.isAfter(currentMonthStart) &&
                t.transactionDate.isBefore(currentMonthEnd)))) {
      categoryTotals[t.categoryId] =
          (categoryTotals[t.categoryId] ?? 0) + t.amount;
    }
  }

  // Return null if no expense transactions
  if (categoryTotals.isEmpty) {
    return null;
  }

  // Find top category
  String? topCategoryId;
  double maxTotal = 0;
  for (final entry in categoryTotals.entries) {
    if (entry.value > maxTotal) {
      maxTotal = entry.value;
      topCategoryId = entry.key;
    }
  }

  if (topCategoryId == null) {
    return null;
  }

  final category = categoryMap[topCategoryId];
  if (category == null) {
    return null;
  }

  final categoryColor = Color(
    int.parse(category.color.replaceFirst('#', 'FF'), radix: 16),
  );
  final categoryIcon = _getIconData(category.icon);

  return AnalyticsInsightModel(
    type: InsightType.topCategory,
    title: 'Chi tiêu nhiều nhất: ${category.name}',
    description: 'Bạn đã chi tiêu $maxTotal ₫ cho ${category.name} trong tháng này',
    categoryName: category.name,
    categoryColor: categoryColor,
    categoryIcon: categoryIcon,
  );
}

/// Computes highest spending day of week insight.
///
/// Returns the day with highest total spending in current month.
AnalyticsInsightModel? _computeHighestSpendingDay(
  List<TransactionModel> transactions,
) {
  final now = DateTime.now();
  final currentMonthStart = DateTime(now.year, now.month, 1);
  final currentMonthEnd = DateTime(now.year, now.month + 1, 1);

  // Day of week totals (0=Monday, 6=Sunday in intl package)
  final dayTotals = List<double>.filled(7, 0);

  // Filter expense transactions for current month
  for (final t in transactions) {
    if (t.type == TransactionType.expense &&
        (t.transactionDate.isAtSameMomentAs(currentMonthStart) ||
            (t.transactionDate.isAfter(currentMonthStart) &&
                t.transactionDate.isBefore(currentMonthEnd)))) {
      final dayIndex = t.transactionDate.weekday - 1; // Convert to 0-6
      dayTotals[dayIndex] += t.amount;
    }
  }

  // Find max spending day
  double maxTotal = 0;
  int maxDayIndex = 0;
  for (int i = 0; i < dayTotals.length; i++) {
    if (dayTotals[i] > maxTotal) {
      maxTotal = dayTotals[i];
      maxDayIndex = i;
    }
  }

  // Return null if no expense transactions
  if (maxTotal == 0) {
    return null;
  }

  // Get Vietnamese day name
  const dayNames = [
    'Thứ hai',
    'Thứ ba',
    'Thứ tư',
    'Thứ năm',
    'Thứ sáu',
    'Thứ bảy',
    'Chủ nhật',
  ];

  final dayName = dayNames[maxDayIndex];

  return AnalyticsInsightModel(
    type: InsightType.highestSpendingDay,
    title: 'Chi tiêu nhiều nhất vào $dayName',
    description: 'Bạn thường chi tiêu nhiều nhất vào $dayName ($maxTotal ₫)',
    dayName: dayName,
  );
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
