import 'package:flutter/material.dart';

/// Insight type representing different analytics insights.
enum InsightType {
  /// Spending increased compared to previous period
  spendingIncrease,

  /// Spending decreased compared to previous period
  spendingDecrease,

  /// Top spending category
  topCategory,

  /// Day of week with highest spending
  highestSpendingDay,

  /// No data available
  noData,
}

/// Direction of change (increase or decrease).
enum ChangeDirection {
  increase,
  decrease,
  neutral,
}

/// Immutable model representing an analytics insight.
///
/// Provides user-friendly spending insights derived from transaction data.
/// Contains the insight type, title, description, and optional details.
class AnalyticsInsightModel {
  /// Type of insight being presented.
  final InsightType type;

  /// Vietnamese title for the insight card.
  final String title;

  /// Vietnamese description with the insight details.
  final String description;

  /// Optional percentage change for comparison insights.
  final double? percentageChange;

  /// Direction of change (for comparison insights).
  final ChangeDirection? changeDirection;

  /// Optional category name for category-based insights.
  final String? categoryName;

  /// Optional category color for visual accent.
  final Color? categoryColor;

  /// Optional category icon for visual accent.
  final IconData? categoryIcon;

  /// Optional day name for day-based insights.
  final String? dayName;

  const AnalyticsInsightModel({
    required this.type,
    required this.title,
    required this.description,
    this.percentageChange,
    this.changeDirection,
    this.categoryName,
    this.categoryColor,
    this.categoryIcon,
    this.dayName,
  });

  /// Creates a copy with optional field replacements.
  AnalyticsInsightModel copyWith({
    InsightType? type,
    String? title,
    String? description,
    double? percentageChange,
    ChangeDirection? changeDirection,
    String? categoryName,
    Color? categoryColor,
    IconData? categoryIcon,
    String? dayName,
  }) {
    return AnalyticsInsightModel(
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      percentageChange: percentageChange ?? this.percentageChange,
      changeDirection: changeDirection ?? this.changeDirection,
      categoryName: categoryName ?? this.categoryName,
      categoryColor: categoryColor ?? this.categoryColor,
      categoryIcon: categoryIcon ?? this.categoryIcon,
      dayName: dayName ?? this.dayName,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AnalyticsInsightModel &&
        other.type == type &&
        other.title == title &&
        other.description == description &&
        other.percentageChange == percentageChange &&
        other.changeDirection == changeDirection &&
        other.categoryName == categoryName &&
        other.categoryColor == categoryColor &&
        other.categoryIcon == categoryIcon &&
        other.dayName == dayName;
  }

  @override
  int get hashCode {
    return Object.hash(
      type,
      title,
      description,
      percentageChange,
      changeDirection,
      categoryName,
      categoryColor,
      categoryIcon,
      dayName,
    );
  }
}
