// Riverpod
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Global loading state provider for application
///
/// Manages loading state across entire application.
/// Used to show full-screen loading overlay during async operations.
class LoadingState {
  /// Whether app is currently in loading state
  final bool isLoading;

  /// Optional loading message to display
  final String? message;

  const LoadingState({
    this.isLoading = false,
    this.message,
  });

  LoadingState copyWith({bool? isLoading, String? message}) {
    return LoadingState(
      isLoading: isLoading ?? this.isLoading,
      message: message ?? this.message,
    );
  }
}

/// Global loading state notifier
///
/// Controls loading state across entire application.
/// Use `ref.read(loadingProvider.notifier).setLoading(true)` to show,
/// and `ref.read(loadingProvider.notifier).setLoading(false)` to hide.
class LoadingNotifier extends StateNotifier<LoadingState> {
  LoadingNotifier() : super(const LoadingState());

  /// Set loading state with optional message
  void setLoading(bool isLoading, {String? message}) {
    state = LoadingState(isLoading: isLoading, message: message);
  }

  /// Show loading state
  void showLoading({String? message}) {
    setLoading(true, message: message);
  }

  /// Hide loading state
  void hideLoading() {
    setLoading(false);
  }
}

/// Global loading provider
///
/// Provides access to loading state across entire application.
///
/// Usage:
/// ```dart
/// // Show loading
/// ref.read(loadingProvider.notifier).showLoading();
///
/// // Hide loading
/// ref.read(loadingProvider.notifier).hideLoading();
///
/// // Watch loading state
/// final isLoading = ref.watch(loadingProvider).isLoading;
/// ```
final loadingProvider = StateNotifierProvider<LoadingNotifier, LoadingState>((ref) {
  return LoadingNotifier();
});
