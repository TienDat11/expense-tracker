// Dart SDK
import 'dart:async';

// Project
import 'package:expense_tracker/data/models/user_model.dart';
import 'package:expense_tracker/data/repositories/auth_repository.dart';
import 'package:expense_tracker/data/services/supabase_service.dart';
// Packages
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase_auth;

/// Authentication state
///
/// Represents current authentication state of application.
/// Contains user data when authenticated, error message when failed.
class AuthState {
  /// Current authenticated user
  final UserModel? user;

  /// Loading state indicator
  final bool isLoading;

  /// Error message if authentication failed
  final String? error;

  /// Creates AuthState with specified values
  ///
  /// Parameters:
  /// - [user]: Currently authenticated user
  /// - [isLoading]: Whether an auth operation is in progress
  /// - [error]: Error message from failed operation
  const AuthState({
    this.user,
    required this.isLoading,
    this.error,
  });

  /// Initial unauthenticated state
  const AuthState.unauthenticated()
      : user = null,
        isLoading = false,
        error = null;

  /// Loading state
  const AuthState.loading()
      : user = null,
        isLoading = true,
        error = null;

  /// Authenticated state
  const AuthState.authenticated(this.user)
      : isLoading = false,
        error = null;

  /// Error state
  const AuthState.error(this.error)
      : user = null,
        isLoading = false;

  /// Creates copy of AuthState with modified fields
  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  /// Checks if state indicates successful authentication
  bool get isAuthenticated => user != null && !isLoading;
}

/// Authentication state notifier for Riverpod
///
/// Manages authentication state and provides methods for
/// sign up, sign in, sign out, and auth state monitoring.
/// Uses [StateNotifier] pattern for reactive state management.
class AuthNotifier extends StateNotifier<AuthState> {
  /// Authentication repository for auth operations
  final AuthRepository _repository;

  /// Stream subscription for auth state changes
  StreamSubscription? _authSubscription;

  /// Creates auth notifier with repository dependency
  ///
  /// Constructor injection enables testing with mock repositories.
  AuthNotifier(this._repository) : super(const AuthState.unauthenticated()) {
    // Listen to auth state changes from repository
    _authSubscription = _repository.authStateChanges().listen(
      (supabase_auth.User? user) {
        if (user != null) {
          // User is authenticated
          state = AuthState.authenticated(UserModel.fromSupabaseUser(user));
        } else {
          // User is not authenticated
          state = const AuthState.unauthenticated();
        }
      },
      onError: (error) {
        // Handle auth stream errors
        state = AuthState.error(error.toString());
      },
    );
  }

  /// Sign up a new user
  ///
  /// Updates state to loading, calls repository,
  /// then updates state with result or error.
  Future<void> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    state = const AuthState.loading();

    try {
      final user = await _repository.signUp(
        email: email,
        password: password,
        fullName: fullName,
      );
      state = AuthState.authenticated(user);
    } catch (e) {
      state = AuthState.error(e is Exception ? e.toString() : 'Unknown error');
    }
  }

  /// Sign in an existing user with email and password
  ///
  /// Updates state to loading, calls repository,
  /// then updates state with result or error.
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AuthState.loading();

    try {
      final user = await _repository.signIn(
        email: email,
        password: password,
      );
      state = AuthState.authenticated(user);
    } catch (e) {
      state = AuthState.error(e is Exception ? e.toString() : 'Unknown error');
    }
  }

  /// Sign out current user
  ///
  /// Updates state to loading, calls repository,
  /// then updates state to unauthenticated.
  Future<void> signOut() async {
    state = const AuthState.loading();

    try {
      await _repository.signOut();
      state = const AuthState.unauthenticated();
    } catch (e) {
      state = AuthState.error(e is Exception ? e.toString() : 'Unknown error');
    }
  }

  /// Check current authentication status
  ///
  /// Queries repository for current user and updates state.
  void checkAuthStatus() {
    final user = _repository.getCurrentUser();
    if (user != null) {
      state = AuthState.authenticated(user);
    } else {
      state = const AuthState.unauthenticated();
    }
  }

  /// Clears any existing error state
  ///
  /// Useful when user navigates away from error screen.
  void clearError() {
    state = state.copyWith(error: null);
  }

  @override
  void dispose() {
    // Cancel auth state subscription
    _authSubscription?.cancel();
    super.dispose();
  }
}

/// Authentication state provider
///
/// Exposes [AuthState] and [AuthNotifier] to widget tree.
/// Use with [Consumer] or [ref.watch] to access auth state.
///
/// Usage:
/// ```dart
/// final authState = ref.watch(authProvider);
/// if (authState.isLoading) {
///   return LoadingIndicator();
/// }
/// if (authState.error != null) {
///   return ErrorMessage(authState.error!);
/// }
/// return HomeScreen(user: authState.user);
/// ```
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final supabaseClient = SupabaseService.instance.client;
  final repository = AuthRepository(supabaseClient);

  return AuthNotifier(repository);
});

/// Supabase service provider
///
/// Provides access to SupabaseService singleton client.
/// This provider should be provided at app root level.
final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService.instance;
});
