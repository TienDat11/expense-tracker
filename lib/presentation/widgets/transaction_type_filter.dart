import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/data/models/transaction_type.dart';
import 'package:flutter/material.dart';

/// Secondary transaction type filter widget.
///
/// Lower visual weight - compact, subtle toggle.
/// Uses icon + label pattern for quick recognition.
/// No "All" option - filtering is handled by time filter.
class TransactionTypeFilter extends StatelessWidget {
  /// Currently selected type (null = show all)
  final TransactionType? selected;

  /// Callback when filter is changed
  final ValueChanged<TransactionType?> onChanged;

  const TransactionTypeFilter({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _TypeFilterButton(
            label: 'Thu nhập',
            icon: Icons.arrow_upward_rounded,
            isSelected: selected == TransactionType.income,
            color: AppColors.success,
            onPressed: () => onChanged(
              selected == TransactionType.income
                  ? null
                  : TransactionType.income,
            ),
          ),
          const SizedBox(width: 12),
          _TypeFilterButton(
            label: 'Chi tiêu',
            icon: Icons.arrow_downward_rounded,
            isSelected: selected == TransactionType.expense,
            color: AppColors.error,
            onPressed: () => onChanged(
              selected == TransactionType.expense
                  ? null
                  : TransactionType.expense,
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact type filter button with icon + label.
class _TypeFilterButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final VoidCallback onPressed;

  const _TypeFilterButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : AppColors.outline.withValues(alpha: 0.4),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? color : theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? color
                    : theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
