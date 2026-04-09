// Flutter
import 'package:flutter/material.dart';

// Project
import 'package:expense_tracker/core/constants/app_colors.dart';

/// Modern minimalist text field widget with Material 3 design
///
/// Provides clean, professional styling with password visibility toggle,
/// validation, and accessibility for all text inputs across the application.
class CustomTextField extends StatefulWidget {
  /// Label text displayed above the input
  final String? labelText;

  /// Hint text displayed when field is empty
  final String? hintText;

  /// Prefix icon or text displayed inside the field
  final Widget? prefixIcon;

  /// Suffix icon or text displayed inside the field
  final Widget? suffixIcon;

  /// Controller for managing text input
  final TextEditingController? controller;

  /// Focus node for managing keyboard focus
  final FocusNode? focusNode;

  /// Text input type
  final TextInputType keyboardType;

  /// Whether text should be obscured (for passwords)
  final bool obscureText;

  /// Maximum number of characters allowed
  final int? maxLength;

  /// Number of lines for multi-line input
  final int? maxLines;

  /// Whether field is enabled for user input
  final bool enabled;

  /// Optional validation function
  final String? Function(String?)? validator;

  /// Callback when text changes
  final ValueChanged<String>? onChanged;

  /// Callback when field is tapped
  final VoidCallback? onTap;

  /// Callback when field is submitted
  final ValueChanged<String>? onFieldSubmitted;

  /// Optional prefix text displayed before input
  final String? prefixText;

  /// Action to trigger when user submits the field
  final TextInputAction? textInputAction;

  /// Creates custom text field with specified properties
  const CustomTextField({
    super.key,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.controller,
    this.focusNode,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.maxLength,
    this.maxLines = 1,
    this.enabled = true,
    this.validator,
    this.onChanged,
    this.onTap,
    this.onFieldSubmitted,
    this.prefixText,
    this.textInputAction,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  /// Local state for obscuring password text
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    // Initialize obscuring state based on widget parameter
    _isObscured = widget.obscureText;
  }

  /// Toggle password visibility
  void _togglePasswordVisibility() {
    setState(() {
      _isObscured = !_isObscured;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.labelText != null) ...[
          const SizedBox(height: 6),
          Text(
            widget.labelText!,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface.withValues(alpha: 0.85),
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          keyboardType: widget.keyboardType,
          obscureText: _isObscured,
          maxLength: widget.maxLength,
          maxLines: widget.maxLines,
          enabled: widget.enabled,
          validator: widget.validator,
          onChanged: widget.onChanged,
          onTap: widget.onTap,
          onFieldSubmitted: widget.onFieldSubmitted,
          textInputAction: widget.textInputAction ??
              (widget.maxLines == 1 ? TextInputAction.done : TextInputAction.newline),
          style: TextStyle(
            fontSize: 16,
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w400,
            height: 1.5,
          ),
          cursorColor: AppColors.primary,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: TextStyle(
              fontSize: 16,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.obscureText
                ? Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: IconButton(
                      icon: Icon(
                        _isObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                        size: 22,
                      ),
                      onPressed: _togglePasswordVisibility,
                      splashRadius: 20,
                    ),
                  )
                : widget.suffixIcon,
            prefixText: widget.prefixText,
            prefix: widget.prefixText != null || widget.prefixIcon != null
                ? const Padding(padding: EdgeInsets.only(left: 16))
                : const SizedBox(width: 16),
            suffix: widget.obscureText || widget.suffixIcon != null
                ? const Padding(padding: EdgeInsets.only(right: 8))
                : const SizedBox(width: 16),
            filled: true,
            fillColor: colorScheme.surfaceContainer,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            counterText: '', // Remove character counter
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.transparent,
                width: 1.0,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.transparent,
                width: 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.8,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.error,
                width: 1.0,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.transparent,
                width: 1.0,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.error,
                width: 1.8,
              ),
            ),
            errorStyle: const TextStyle(
              fontSize: 12,
              color: AppColors.error,
              fontWeight: FontWeight.w500,
            ),
            floatingLabelBehavior: FloatingLabelBehavior.never,
          ),
        ),
      ],
    );
  }
}
