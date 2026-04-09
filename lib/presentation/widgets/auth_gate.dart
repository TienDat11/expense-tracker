import 'package:expense_tracker/presentation/providers/auth_provider.dart';
import 'package:expense_tracker/presentation/screens/auth/login_screen.dart';
import 'package:expense_tracker/presentation/screens/home/home_screen.dart';
import 'package:expense_tracker/presentation/screens/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Authentication gate widget.
///
/// Single source of truth for app navigation based on auth state.
/// Replaces imperative navigation in individual screens with declarative approach.
///
/// Key responsibilities:
/// - Listen to auth state from AuthProvider
/// - Show loading state during auth operations
/// - Navigate deterministically when auth state changes
/// - Prevent multiple navigation attempts
///
/// According to Supabase best practices:
/// - onAuthStateChange is the SINGLE source of auth state truth
/// - Navigation should respond to auth state changes, not user actions directly
class AuthGate extends ConsumerStatefulWidget {
  /// Widget to show when authenticated
  /// Optional: defaults to HomeScreen
  final Widget? authenticatedChild;

  /// Widget to show when unauthenticated
  /// Optional: defaults to LoginScreen
  final Widget? unauthenticatedChild;

  /// Widget to show during loading
  /// Optional: uses default loading indicator
  final Widget? loadingChild;

  const AuthGate({
    super.key,
    this.authenticatedChild,
    this.unauthenticatedChild,
    this.loadingChild,
  });

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  @override
  Widget build(BuildContext context) {
    // Watch auth state for reactive updates
    final authState = ref.watch(authProvider);

    debugPrint('[AUTH_GATE] Auth state: isLoading=${authState.isLoading}, user=${authState.user != null}');
    debugPrint('[AUTH_GATE] isAuthenticated: ${authState.isAuthenticated}');

    // Build appropriate widget based on auth state
    if (authState.isLoading) {
      // Show splash screen while loading auth state
      return widget.loadingChild ?? const SplashScreen();
    }

    if (authState.isAuthenticated) {
      // User is authenticated
      // Use the provided child or default to HomeScreen
      return widget.authenticatedChild ?? const HomeScreen();
    }

    // User is not authenticated
    // Use the provided child or default to login
    return widget.unauthenticatedChild ?? const LoginScreen();
  }
}
