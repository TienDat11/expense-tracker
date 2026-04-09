import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/domain/models/analytics_insight_model.dart';
import 'package:flutter/material.dart';

/// Widget displaying a single analytics insight card.
///
/// Shows insight with appropriate icon, title, and description.
/// Uses minimal, premium design following app guidelines.
class AnalyticsInsightCard extends StatelessWidget {
  final AnalyticsInsightModel insight;

  const AnalyticsInsightCard({
    super.key,
    required this.insight,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.outline,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildIcon(context),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  insight.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                if (insight.percentageChange != null) ...[
                  const SizedBox(height: 8),
                  _buildPercentageBadge(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the insight icon based on type.
  Widget _buildIcon(BuildContext context) {
    Color iconColor;
    Color iconBackgroundColor;
    IconData iconData;

    switch (insight.type) {
      case InsightType.spendingIncrease:
        iconColor = AppColors.error;
        iconBackgroundColor = AppColors.error.withValues(alpha: 0.1);
        iconData = Icons.trending_up;
        break;
      case InsightType.spendingDecrease:
        iconColor = AppColors.success;
        iconBackgroundColor = AppColors.success.withValues(alpha: 0.1);
        iconData = Icons.trending_down;
        break;
      case InsightType.topCategory:
        iconColor = insight.categoryColor ?? AppColors.primary;
        iconBackgroundColor = (insight.categoryColor ?? AppColors.primary)
            .withValues(alpha: 0.1);
        iconData = insight.categoryIcon ?? Icons.star;
        break;
      case InsightType.highestSpendingDay:
        iconColor = AppColors.info;
        iconBackgroundColor = AppColors.info.withValues(alpha: 0.1);
        iconData = Icons.calendar_today;
        break;
      case InsightType.noData:
        iconColor = AppColors.textSecondary;
        iconBackgroundColor = AppColors.textSecondary.withValues(alpha: 0.1);
        iconData = Icons.info_outline;
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: iconBackgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 22,
      ),
    );
  }

  /// Builds the percentage change badge.
  Widget _buildPercentageBadge() {
    final direction = insight.changeDirection;
    if (direction == null || insight.percentageChange == null) {
      return const SizedBox.shrink();
    }

    final color = direction == ChangeDirection.increase
        ? AppColors.error
        : AppColors.success;
    final icon = direction == ChangeDirection.increase
        ? Icons.arrow_upward_rounded
        : Icons.arrow_downward_rounded;
    final text = direction == ChangeDirection.increase
        ? '+${insight.percentageChange!.toInt()}%'
        : '-${insight.percentageChange!.toInt()}%';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
