import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// Reusable widget for transaction date group header.
///
/// Displays formatted date label with optional transaction count.
/// Clean, minimalist design with subtle visual hierarchy.
/// Consistent with purple theme and premium UI.
class TransactionGroupHeader extends StatelessWidget {
  /// Date label to display (e.g., "Hôm nay", "Hôm qua", "12/01/2026")
  final String label;

  /// Number of transactions in this group (optional)
  final int? count;

  const TransactionGroupHeader({
    super.key,
    required this.label,
    this.count,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
                letterSpacing: 0.2,
              ),
            ),
          ),
          if (count != null && count! > 0) ...[
            const SizedBox(width: 8),
            Text(
              '$count giao dịch',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
