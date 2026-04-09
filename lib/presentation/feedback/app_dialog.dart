import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// Dialog action button configuration.
///
/// Encapsulates button text, callback, and styling for dialog actions.
class DialogAction {
  /// Button label text.
  final String label;

  /// Callback when button is pressed.
  final VoidCallback? onPressed;

  /// Whether this is a destructive action (applies error color).
  final bool isDestructive;

  /// Whether this is the primary action (applies primary styling).
  final bool isPrimary;

  const DialogAction({
    required this.label,
    this.onPressed,
    this.isDestructive = false,
    this.isPrimary = false,
  });
}

/// Modern custom dialog widget replacing AlertDialog.
///
/// Designed following 2024-2025 mobile dialog UX patterns:
/// - Rounded corners (16dp radius)
/// - Constrained width (max 340dp) for mobile readability
/// - Clear visual hierarchy: title → content → actions
/// - Subtle scale + fade animation for premium feel
/// - Consistent padding and spacing
///
/// Usage:
/// ```dart
/// final confirmed = await AppDialog.confirm(
///   context,
///   title: 'Xóa giao dịch',
///   content: 'Bạn có chắc muốn xóa giao dịch này không?',
/// );
/// ```
class AppDialog extends StatelessWidget {
  /// Dialog title (required).
  final String title;

  /// Dialog content/message (optional).
  final String? content;

  /// Custom content widget (takes precedence over content string).
  final Widget? contentWidget;

  /// Action buttons displayed at bottom.
  final List<DialogAction> actions;

  /// Optional icon displayed above title.
  final IconData? icon;

  /// Icon color (defaults to primary).
  final Color? iconColor;

  const AppDialog({
    super.key,
    required this.title,
    this.content,
    this.contentWidget,
    this.actions = const [],
    this.icon,
    this.iconColor,
  });

  /// Shows a confirmation dialog with Cancel/Confirm actions.
  ///
  /// Returns true if confirmed, false if cancelled or dismissed.
  /// This is the most common dialog pattern in the app.
  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    String? content,
    String cancelLabel = 'Hủy',
    String confirmLabel = 'Xác nhận',
    bool isDestructive = false,
  }) async {
    final result = await show<bool>(
      context,
      title: title,
      content: content,
      actions: [
        DialogAction(
          label: cancelLabel,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        DialogAction(
          label: confirmLabel,
          onPressed: () => Navigator.of(context).pop(true),
          isDestructive: isDestructive,
          isPrimary: !isDestructive,
        ),
      ],
    );
    return result ?? false;
  }

  /// Shows a destructive confirmation dialog (e.g., delete).
  ///
  /// Visual emphasis on the destructive nature of the action.
  static Future<bool> confirmDestructive(
    BuildContext context, {
    required String title,
    String? content,
    bool? isLogout,
    String cancelLabel = 'Hủy',
    String confirmLabel = 'Xóa',
  }) {
    return confirm(
      context,
      title: title,
      content: content,
      cancelLabel: cancelLabel,
      confirmLabel: isLogout != null ? 'Đăng xuất' : confirmLabel,
      isDestructive: true,
    );
  }

  /// Shows an alert dialog with single OK action.
  ///
  /// Used for informational messages that only need acknowledgment.
  static Future<void> alert(
    BuildContext context, {
    required String title,
    String? content,
    String okLabel = 'OK',
    IconData? icon,
    Color? iconColor,
  }) async {
    await show<void>(
      context,
      title: title,
      content: content,
      icon: icon,
      iconColor: iconColor,
      actions: [
        DialogAction(
          label: okLabel,
          onPressed: () => Navigator.of(context).pop(),
          isPrimary: true,
        ),
      ],
    );
  }

  /// Shows a custom dialog with full configuration.
  ///
  /// Base method used by convenience methods.
  /// Applies custom animation for premium feel.
  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    String? content,
    Widget? contentWidget,
    List<DialogAction> actions = const [],
    IconData? icon,
    Color? iconColor,
    bool barrierDismissible = true,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: 'Dismiss',
      barrierColor: AppColors.accent,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return AppDialog(
          title: title,
          content: content,
          contentWidget: contentWidget,
          actions: actions,
          icon: icon,
          iconColor: iconColor,
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        // Scale + fade animation for modern dialog feel
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
          reverseCurve: Curves.easeIn,
        );

        return ScaleTransition(
          scale: Tween<double>(begin: 0.9, end: 1.0).animate(curvedAnimation),
          child: FadeTransition(
            opacity: curvedAnimation,
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          constraints: const BoxConstraints(maxWidth: 340),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.15),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with optional icon
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Column(
                  children: [
                    if (icon != null) ...[
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: (iconColor ?? AppColors.primary)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          icon,
                          color: iconColor ?? AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Content
              if (contentWidget != null || content != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                  child: contentWidget ??
                      Text(
                        content!,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                ),

              // Actions
              if (actions.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: actions.asMap().entries.map((entry) {
                      final index = entry.key;
                      final action = entry.value;
                      final isLast = index == actions.length - 1;

                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: index > 0 ? 8 : 0),
                          child: _buildActionButton(context, action, isLast),
                        ),
                      );
                    }).toList(),
                  ),
                )
              else
                const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds an action button with appropriate styling.
  Widget _buildActionButton(
    BuildContext context,
    DialogAction action,
    bool isLast,
  ) {
    if (action.isPrimary) {
      return ElevatedButton(
        onPressed: action.onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          action.label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      );
    }

    if (action.isDestructive) {
      return ElevatedButton(
        onPressed: action.onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.error,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          action.label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      );
    }

    // Secondary/cancel button - red outline for cancel action
    return OutlinedButton(
      onPressed: action.onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.error,
        side: const BorderSide(
          color: AppColors.error,
          width: 1.5,
        ),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        action.label,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
    );
  }
}
