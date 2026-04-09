// Flutter
import 'package:flutter/material.dart';

// Project
import 'package:expense_tracker/core/constants/app_colors.dart';

/// Custom button widget following Material 3 design
///
/// Provides primary, secondary, and tertiary button variants
/// with consistent styling, loading states, and touch targets.
/// Uses design tokens from app_colors.dart.
class CustomButton extends StatelessWidget {
  /// Button variant for styling
  final ButtonVariant variant;

  /// Text to display on button
  final String text;

  /// Callback when button is pressed
  final VoidCallback? onPressed;

  /// Whether button is in loading state
  ///
  /// Shows circular progress indicator instead of text.
  final bool isLoading;

  /// Whether button should take full width of parent
  ///
  /// Useful for form submit buttons in dialogs/bottom sheets.
  final bool fullWidth;

  /// Optional icon to display before text
  final IconData? icon;

  /// Button elevation level
  ///
  /// Higher values create more prominent shadows.
  final int? elevation;

  /// Creates custom button with specified properties
  const CustomButton({
    super.key,
    required this.text,
    this.variant = ButtonVariant.primary,
    this.onPressed,
    this.isLoading = false,
    this.fullWidth = false,
    this.icon,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 18),
                  const SizedBox(width: 8),
                  Text(text),
                ],
              )
            : Text(text);

    final buttonStyle = _getButtonStyle(context);

    if (fullWidth) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: buttonStyle,
          onPressed: isLoading ? null : onPressed,
          child: child,
        ),
      );
    }

    return ElevatedButton(
      style: buttonStyle,
      onPressed: isLoading ? null : onPressed,
      child: child,
    );
  }

  /// Returns button style based on variant
  ///
  /// Maps variant to Material 3 styling with design tokens.
  ButtonStyle _getButtonStyle(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    switch (variant) {
      case ButtonVariant.primary:
        return ButtonStyle(
          elevation: WidgetStateProperty.all((elevation ?? 2).toDouble()),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return colorScheme.onSurface.withValues(alpha: 0.12);
            }
            return AppColors.primary;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return colorScheme.onSurface.withValues(alpha: 0.38);
            }
            return Colors.white;
          }),
        );

      case ButtonVariant.secondary:
        return ButtonStyle(
          elevation: WidgetStateProperty.all((elevation ?? 1).toDouble()),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return colorScheme.onSurface.withValues(alpha: 0.04);
            }
            return AppColors.primary.withValues(alpha: 0.1);
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return colorScheme.onSurface.withValues(alpha: 0.38);
            }
            return AppColors.primary;
          }),
        );

      case ButtonVariant.tertiary:
        return ButtonStyle(
          elevation: WidgetStateProperty.all(0.0),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return colorScheme.onSurface.withValues(alpha: 0.38);
            }
            return Colors.transparent;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return colorScheme.onSurface.withValues(alpha: 0.38);
            }
            return AppColors.primary;
          }),
        );
    }
  }
}

/// Button variant enum for styling
///
/// Defines available button styles for consistent UI.
enum ButtonVariant {
  /// Primary call-to-action button
  primary,

  /// Secondary button for alternative actions
  secondary,

  /// Tertiary button for less important actions
  tertiary,
}
