import 'package:flutter/material.dart';

/// Immutable analytics model for category breakdown statistics.
///
/// Holds aggregated data for a single category including
/// total amount, transaction count, and percentage share.
/// Used for charts and category breakdown lists.
class CategoryStatsModel {
  /// Unique identifier of the category.
  final String categoryId;

  /// Display name of the category.
  final String categoryName;

  /// Color associated with the category for visual representation.
  final Color categoryColor;

  /// Icon associated with the category for visual representation.
  final IconData categoryIcon;

  /// Sum of all transaction amounts for this category.
  final double totalAmount;

  /// Number of transactions belonging to this category.
  final int transactionCount;

  /// Percentage share of total amount (0.0 to 100.0).
  final double percentage;

  const CategoryStatsModel({
    required this.categoryId,
    required this.categoryName,
    required this.categoryColor,
    required this.categoryIcon,
    required this.totalAmount,
    required this.transactionCount,
    required this.percentage,
  });

  /// Creates a copy with optional field replacements.
  ///
  /// Enables immutable updates without modifying original instance.
  CategoryStatsModel copyWith({
    String? categoryId,
    String? categoryName,
    Color? categoryColor,
    IconData? categoryIcon,
    double? totalAmount,
    int? transactionCount,
    double? percentage,
  }) {
    return CategoryStatsModel(
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      categoryColor: categoryColor ?? this.categoryColor,
      categoryIcon: categoryIcon ?? this.categoryIcon,
      totalAmount: totalAmount ?? this.totalAmount,
      transactionCount: transactionCount ?? this.transactionCount,
      percentage: percentage ?? this.percentage,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoryStatsModel &&
        other.categoryId == categoryId &&
        other.categoryName == categoryName &&
        other.categoryColor == categoryColor &&
        other.totalAmount == totalAmount &&
        other.transactionCount == transactionCount &&
        other.percentage == percentage;
  }

  @override
  int get hashCode {
    return Object.hash(
      categoryId,
      categoryName,
      categoryColor,
      categoryIcon.hashCode,
      totalAmount,
      transactionCount,
      percentage,
    );
  }
}
