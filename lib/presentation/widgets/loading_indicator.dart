// Flutter
import 'package:flutter/material.dart';

/// Loading indicator widget
///
/// Provides consistent loading state display across the application.
/// Supports full-screen and inline variants with custom messages.
class LoadingIndicator extends StatelessWidget {
  /// Whether to show as full-screen overlay
  ///
  /// When true, shows centered circular progress with dimmed background.
  /// When false, shows inline circular progress.
  final bool fullScreen;

  /// Optional custom message to display below indicator
  ///
  /// If provided, shows text in full-screen mode.
  final String? message;

  /// Size of the circular progress indicator
  ///
  /// Default is 40dp, can be customized for specific use cases.
  final double? size;

  /// Color of the progress indicator
  ///
  /// Defaults to primary brand color.
  final Color? color;

  /// Background color for full-screen overlay
  ///
  /// Defaults to semi-transparent black.
  final Color? overlayColor;

  /// Creates loading indicator with specified properties
  const LoadingIndicator({
    super.key,
    this.fullScreen = false,
    this.message,
    this.size,
    this.color,
    this.overlayColor,
  });

  @override
  Widget build(BuildContext context) {
    final indicator = SizedBox(
      width: size ?? 40,
      height: size ?? 40,
      child: CircularProgressIndicator(
        strokeWidth: 3,
        valueColor: color != null
            ? AlwaysStoppedAnimation<Color>(color!)
            : null,
      ),
    );

    if (fullScreen) {
      return _buildFullScreen(context, indicator);
    }

    return indicator;
  }

  /// Builds full-screen loading overlay
  ///
  /// Shows circular progress centered on dimmed background
  /// with optional message below.
  Widget _buildFullScreen(BuildContext context, Widget indicator) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: overlayColor ?? theme.colorScheme.onSurface.withValues(alpha: 0.5),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              indicator,
              if (message != null) ...[
                const SizedBox(height: 24),
                Text(
                  message!,
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
