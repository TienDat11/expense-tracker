import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/data/models/category_model.dart' as models;
import 'package:expense_tracker/data/models/transaction_model.dart';
import 'package:expense_tracker/data/models/transaction_type.dart';
import 'package:flutter/material.dart';

/// Reusable widget for displaying a transaction item in list.
///
/// Shows transaction icon, category name, amount, date, and note.
/// Applies color coding based on transaction type (income/expense).
class TransactionListItem extends StatelessWidget {
  /// Transaction data to display
  final TransactionModel transaction;

  /// Category data for icon and color
  final models.CategoryModel? category;

  /// Callback when item is tapped
  final VoidCallback onTap;

  const TransactionListItem({
    super.key,
    required this.transaction,
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isExpense = transaction.type == TransactionType.expense;
    final amountColor = isExpense ? AppColors.textPrimary : AppColors.success;
    final amountPrefix = isExpense ? '-' : '+';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.outline,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            _buildCategoryIcon(),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category?.name ?? 'Không rõ danh mục',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(transaction.transactionDate),
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$amountPrefix${CurrencyFormatter.format(transaction.amount)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: amountColor,
                  ),
                ),
                if (transaction.note != null && transaction.note!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  SizedBox(
                    width: 120,
                    child: Text(
                      transaction.note!,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Builds category icon container with proper color.
  Widget _buildCategoryIcon() {
    final iconColor = category != null
        ? Color(int.parse(category!.color.replaceAll('#', '0xFF')))
        : AppColors.textSecondary;

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        _getIconData(category?.icon),
        color: iconColor,
        size: 22,
      ),
    );
  }

  /// Maps icon string to IconData.
  IconData _getIconData(String? iconString) {
    if (iconString == null) return Icons.category;

    try {
      return IconData(int.parse(iconString), fontFamily: 'MaterialIcons');
    } catch (_) {
      return Icons.category;
    }
  }

  /// Formats transaction date for display.
  ///
  /// Shows "Hôm nay", "Hôm qua" or DD/MM/YYYY format.
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final transactionDay = DateTime(date.year, date.month, date.day);

    final difference = today.difference(transactionDay).inDays;

    if (difference == 0) return 'Hôm nay';
    if (difference == 1) return 'Hôm qua';
    if (difference == -1) return 'Ngày mai';

    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
