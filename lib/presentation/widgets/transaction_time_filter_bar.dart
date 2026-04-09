import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/presentation/providers/transaction_filter_provider.dart';
import 'package:flutter/material.dart';

/// Horizontal scrollable time filter bar with chip-style items.
///
/// Premium, mobile-first design with natural-width chips.
/// Eliminates visual compression from segmented controls.
/// Smooth horizontal scrolling with clear active states.
class TransactionTimeFilterBar extends StatelessWidget {
  /// Currently selected date range
  final DateRangeFilter selected;

  /// Callback when filter is changed
  final ValueChanged<DateRangeFilter> onChanged;

  const TransactionTimeFilterBar({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.outline.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const BouncingScrollPhysics(),
        itemCount: DateRangeFilter.values.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final filter = DateRangeFilter.values[index];
          final label = _getFilterLabel(filter);

          return _TimeFilterChip(
            label: label,
            isSelected: filter == selected,
            onPressed: () => onChanged(filter),
          );
        },
      ),
    );
  }

  /// Returns Vietnamese label for each filter option.
  String _getFilterLabel(DateRangeFilter filter) {
    switch (filter) {
      case DateRangeFilter.all:
        return 'Tất cả';
      case DateRangeFilter.today:
        return 'Hôm nay';
      case DateRangeFilter.thisWeek:
        return 'Tuần này';
      case DateRangeFilter.thisMonth:
        return 'Tháng này';
      case DateRangeFilter.custom:
        return 'Tùy chọn';
    }
  }
}

/// Individual time filter chip with natural width.
///
/// Chip-style design with rounded corners and clear states.
/// Width adjusts naturally to text content.
class _TimeFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  const _TimeFilterChip({
    required this.label,
    required this.isSelected,
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
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.outline.withValues(alpha: 0.5),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected
                ? Colors.white
                : theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }
}
