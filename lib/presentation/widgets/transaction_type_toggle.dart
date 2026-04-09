import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/data/models/transaction_type.dart';
import 'package:flutter/material.dart';

/// Toggle switch for selecting income vs expense type.
///
/// Uses Material 3 SegmentedButton for native feel.
/// Colors selection based on transaction type for quick visual identification.
class TransactionTypeToggle extends StatelessWidget {
  /// Currently selected transaction type.
  final TransactionType selectedType;

  /// Callback when user selects a type.
  final ValueChanged<TransactionType> onChanged;

  const TransactionTypeToggle({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: SegmentedButton<TransactionType>(
        segments: const [
          ButtonSegment(
            value: TransactionType.expense,
            icon: Icon(Icons.arrow_downward_rounded),
            label: Text('Chi tiêu'),
          ),
          ButtonSegment(
            value: TransactionType.income,
            icon: Icon(Icons.arrow_upward_rounded),
            label: Text('Thu nhập'),
          ),
        ],
        selected: {selectedType},
        onSelectionChanged: (Set<TransactionType> newSelection) {
          if (newSelection.isNotEmpty) {
            onChanged(newSelection.first);
          }
        },
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.primary;
            }
            return AppColors.outline;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.white;
            }
            return theme.colorScheme.onSurface.withValues(alpha: 0.7);
          }),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}
