// Flutter
import 'package:flutter/material.dart';

// Riverpod
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project
import 'package:expense_tracker/core/providers/loading_provider.dart';

/// Full-screen loading overlay widget
///
/// Displays semi-transparent black overlay with circular progress indicator.
/// Used across entire application for consistent loading UX.
class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer(
      builder: (context, ref, child) {
        final loadingState = ref.watch(loadingProvider);

        if (!loadingState.isLoading) {
          return const SizedBox.shrink();
        }

        return Container(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Circular progress indicator
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.surface),
                  strokeWidth: 3,
                ),
                if (loadingState.message != null) ...[
                  const SizedBox(height: 16),
                  // Optional loading message
                  Text(
                    loadingState.message!,
                    style: TextStyle(
                      color: theme.colorScheme.surface,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
