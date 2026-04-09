import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Large input field for transaction amount entry.
///
/// Displays currency prefix (₫), uses number-only keyboard,
/// and formats amount for Vietnamese Dong currency.
class TransactionAmountField extends StatelessWidget {
  /// Current amount value in the field.
  final double amount;

  /// Callback when amount changes.
  final ValueChanged<double> onChanged;

  /// Label displayed above the input.
  final String labelText;

  /// Optional error message to display.
  final String? errorText;

  /// Whether field is disabled (e.g., during submission).
  final bool enabled;

  /// Focus node for keyboard management.
  final FocusNode? focusNode;

  const TransactionAmountField({
    super.key,
    required this.amount,
    required this.onChanged,
    this.labelText = 'Số tiền',
    this.errorText,
    this.enabled = true,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: errorText != null
                  ? AppColors.error
                  : AppColors.outline,
              width: 1,
            ),
          ),
          child: TextField(
            enabled: enabled,
            focusNode: focusNode,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              hintText: '0',
              hintStyle: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              ),
              prefix: const Text(
                '₫ ',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
            inputFormatters: [
              CurrencyInputFormatter(),
            ],
            onChanged: (value) {
              if (value.isEmpty) {
                onChanged(0);
                return;
              }
              final parsed = double.tryParse(value.replaceAll(',', '.'));
              if (parsed == null) return;
              onChanged(parsed);
            },
          ),
        ),
        if (errorText == null)
          const SizedBox(height: 8)
        else
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Text(
              errorText!,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.error,
              ),
            ),
          ),
      ],
    );
  }
}

/// Formatter for Vietnamese Dong currency input.
///
/// Removes non-numeric characters except decimal point,
/// limits to 2 decimal places for currency precision.
class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(',', '.');

    if (text.isEmpty) return newValue;

    final number = double.tryParse(text);
    if (number == null) return oldValue;

    final parts = text.split('.');
    final integerPart = parts[0];
    final decimalPart = parts.length > 1 ? parts[1] : '';

    final formattedInteger = integerPart.isEmpty
        ? '0'
        : integerPart.length > 15
            ? integerPart.substring(0, 15)
            : integerPart;

    final formattedDecimal = decimalPart.length > 2
        ? decimalPart.substring(0, 2)
        : decimalPart;

    final formattedText = decimalPart.isEmpty
        ? formattedInteger
        : '$formattedInteger.$formattedDecimal';

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(
        offset: formattedText.length,
        affinity: TextAffinity.downstream,
      ),
    );
  }
}
