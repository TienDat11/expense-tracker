import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// Toast variant types for semantic feedback.
///
/// Each variant applies distinct visual styling to communicate
/// nature of message to users at a glance.
enum ToastType {
  /// Positive confirmation (e.g., saved, created, deleted)
  success,

  /// Error or failure notification
  error,

  /// Neutral informational message
  info,

  /// Warning that requires attention
  warning,
}

/// Modern floating toast notification widget.
///
/// Replaces SnackBar with a premium card-style overlay that provides
/// non-blocking feedback. Designed following 2024-2025 mobile UI trends:
/// - Floating rounded card container
/// - Icon + message horizontal layout
/// - Subtle shadow for depth
/// - Auto-dismiss after configurable duration
///
/// Usage:
/// ```dart
/// AppToast.show(
///   context,
///   message: 'Đã lưu thành công!',
///   type: ToastType.success,
/// );
/// ```
class AppToast extends StatelessWidget {
  /// The message to display in toast.
  final String message;

  /// Visual variant determining icon and colors.
  final ToastType type;

  /// Optional callback when toast is dismissed.
  final VoidCallback? onDismiss;

  const AppToast({
    super.key,
    required this.message,
    required this.type,
    this.onDismiss,
  });

  /// Shows a toast overlay using Overlay API.
  ///
  /// This approach is preferred over SnackBar because:
  /// - Does not depend on Scaffold
  /// - Allows custom positioning (top of screen)
  /// - More control over animation and styling
  /// - Non-blocking and does not push content
  ///
  /// IMPORTANT: Uses addPostFrameCallback to delay overlay insertion until
  /// after current frame completes. This prevents EditableText assertion
  /// failure when toast is shown while TextField has active IME batch edit.
  /// Also unfocuses any currently focused text field to close IME.
  static void show(
    BuildContext context, {
    required String message,
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    // Unfocus any currently focused text field to close IME
    FocusManager.instance.primaryFocus?.unfocus();

    // Delay overlay insertion until after current frame completes
    // This ensures IME batch edit completes before inserting overlay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final overlay = Overlay.of(context);

      late OverlayEntry entry;

      entry = OverlayEntry(
        builder: (context) => _ToastOverlayWidget(
          message: message,
          type: type,
          duration: duration,
          onDismiss: () => entry.remove(),
        ),
      );

      overlay.insert(entry);
    });
  }

  /// Convenience method for success toast.
  static void success(BuildContext context, String message) {
    show(context, message: message, type: ToastType.success);
  }

  /// Convenience method for error toast.
  static void error(BuildContext context, String message) {
    show(context, message: message, type: ToastType.error);
  }

  /// Convenience method for info toast.
  static void info(BuildContext context, String message) {
    show(context, message: message, type: ToastType.info);
  }

  /// Convenience method for warning toast.
  static void warning(BuildContext context, String message) {
    show(context, message: message, type: ToastType.warning);
  }

  @override
  Widget build(BuildContext context) {
    return _ToastCard(
      message: message,
      type: type,
      onDismiss: onDismiss,
    );
  }
}

/// Internal overlay widget that handles animation and auto-dismiss.
///
/// Uses AnimationController with proper disposal following Flutter best practices.
/// Animation: fade + slide from top for natural entry/exit feel.
class _ToastOverlayWidget extends StatefulWidget {
  final String message;
  final ToastType type;
  final Duration duration;
  final VoidCallback onDismiss;

  const _ToastOverlayWidget({
    required this.message,
    required this.type,
    required this.duration,
    required this.onDismiss,
  });

  @override
  State<_ToastOverlayWidget> createState() => _ToastOverlayWidgetState();
}

class _ToastOverlayWidgetState extends State<_ToastOverlayWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    // Fade animation for smooth entry/exit
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );

    // Slide from top for natural gravity feel
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    ));

    _controller.forward();

    // Auto-dismiss after duration
    Future.delayed(widget.duration, () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Plays exit animation then removes overlay.
  Future<void> _dismiss() async {
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    // Position at top with safe area padding
    final topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      top: topPadding + 16,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: _dismiss,
              child: _ToastCard(
                message: widget.message,
                type: widget.type,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Visual toast card component.
///
/// Separated from overlay logic for potential standalone use.
/// Uses design tokens from AppColors for consistency.
class _ToastCard extends StatelessWidget {
  final String message;
  final ToastType type;
  final VoidCallback? onDismiss;

  const _ToastCard({
    required this.message,
    required this.type,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getTypeConfig(type);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: config.iconColor.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: config.iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              config.icon,
              color: config.iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: config.textColor,
                height: 1.3,
              ),
            ),
          ),
          if (onDismiss != null)
            GestureDetector(
              onTap: onDismiss,
              child: Icon(
                Icons.close_rounded,
                color: config.textColor.withValues(alpha: 0.5),
                size: 18,
              ),
            ),
        ],
      ),
    );
  }

  /// Returns visual configuration based on toast type.
  ///
  /// Uses semantic colors from design system for consistency.
  _ToastConfig _getTypeConfig(ToastType type) {
    switch (type) {
      case ToastType.success:
        return const _ToastConfig(
          icon: Icons.check_circle_rounded,
          iconColor: AppColors.success,
          backgroundColor: AppColors.surface,
          textColor: AppColors.textPrimary,
        );
      case ToastType.error:
        return const _ToastConfig(
          icon: Icons.error_rounded,
          iconColor: AppColors.error,
          backgroundColor: AppColors.surface,
          textColor: AppColors.textPrimary,
        );
      case ToastType.warning:
        return const _ToastConfig(
          icon: Icons.warning_rounded,
          iconColor: AppColors.warning,
          backgroundColor: AppColors.surface,
          textColor: AppColors.textPrimary,
        );
      case ToastType.info:
        return const _ToastConfig(
          icon: Icons.info_rounded,
          iconColor: AppColors.info,
          backgroundColor: AppColors.surface,
          textColor: AppColors.textPrimary,
        );
    }
  }
}

/// Internal configuration class for toast styling.
class _ToastConfig {
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final Color textColor;

  const _ToastConfig({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.textColor,
  });
}
