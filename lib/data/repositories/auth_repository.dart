// Dart SDK
import 'dart:async';

// Flutter
import 'package:flutter/foundation.dart';

// Packages
import 'package:supabase_flutter/supabase_flutter.dart' as supabase_auth;

// Project
import 'package:expense_tracker/data/models/user_model.dart';
import 'package:expense_tracker/core/exceptions/server_exception.dart';

/// Authentication exception for auth-specific errors (internal app error)
///
/// Thrown when authentication operations fail due to validation
/// or API errors. Provides user-friendly error messages.
/// Note: Renamed from AuthException to avoid conflict with Supabase's AuthException.
class AppAuthException implements Exception {
  /// Human-readable error message
  final String message;

  /// Error code for programmatic handling
  ///
  /// Possible values: 'invalid_email', 'weak_password', 'user_exists', etc.
  final String? code;

  const AppAuthException(this.message, {this.code});

  @override
  String toString() => 'AppAuthException: $message';
}

/// Repository for authentication operations
///
/// Encapsulates all Supabase authentication logic.
/// Provides methods for user signup, login, logout, and session management.
/// Throws [AppAuthException] for validation errors and [ServerException] for API errors.
class AuthRepository {
  /// Supabase client for auth operations
  final supabase_auth.SupabaseClient _client;

  /// Creates auth repository with Supabase client dependency
  ///
  /// Constructor injection enables testing with mock clients.
  const AuthRepository(supabase_auth.SupabaseClient client) : _client = client;

  /// Sign up a new user with email and password
  ///
  /// Validates input before calling Supabase API.
  /// Throws [AppAuthException] for validation errors.
  /// Throws [ServerException] for API failures.
  ///
  /// Parameters:
  /// - [email]: User's email address (must be valid format)
  /// - [password]: User's password (must be at least 6 characters)
  /// - [fullName]: Optional display name for user profile
  ///
  /// Returns: [UserModel] with created user data
  Future<UserModel> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    // Validate email format
    _validateEmail(email);

    // Validate password strength
    _validatePassword(password);

    try {
      // Sign up user with Supabase
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: fullName != null
            ? {'full_name': fullName}
            : null,
      );

      // Get the created user from response
      final user = response.user;
      if (user == null) {
        throw const ServerException('User creation failed: No user returned from API');
      }

      // Return UserModel created from Supabase user
      return UserModel.fromSupabaseUser(user);
    } on AppAuthException {
      // Re-throw our validation exceptions
      rethrow;
    } on supabase_auth.AuthException catch (e, stackTrace) {
      // ============ DEBUG: LOG RAW SUPABASE ERROR ============
      debugPrint('[AUTH_DEBUG] ❌ RAW SUPABASE AuthException in signUp():');
      debugPrint('[AUTH_DEBUG]   - message: ${e.message}');
      debugPrint('[AUTH_DEBUG]   - statusCode: ${e.statusCode}');
      debugPrint('[AUTH_DEBUG]   - stackTrace: $stackTrace');
      // ========================================================

      // Throw with REAL error message from Supabase
      throw ServerException('Supabase Auth Error: ${e.message} (code: ${e.statusCode})');
    } catch (e, stackTrace) {
      // ============ DEBUG: LOG RAW GENERAL ERROR ============
      debugPrint('[AUTH_DEBUG] ❌ RAW GENERAL Exception in signUp():');
      debugPrint('[AUTH_DEBUG]   - type: ${e.runtimeType}');
      debugPrint('[AUTH_DEBUG]   - message: $e');
      debugPrint('[AUTH_DEBUG]   - stackTrace: $stackTrace');
      // ========================================================

      // Convert Supabase errors to ServerException with real message
      throw ServerException.fromError(e);
    }
  }

  /// Sign in an existing user with email and password
  ///
  /// Validates input before calling Supabase API.
  /// Throws [AppAuthException] for validation errors.
  /// Throws [ServerException] for API failures.
  ///
  /// Parameters:
  /// - [email]: User's email address
  /// - [password]: User's password
  ///
  /// Returns: [UserModel] with authenticated user data
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    // Validate email format
    _validateEmail(email);

    // Validate password strength
    _validatePassword(password);

    try {
      // Sign in user with Supabase
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      // Get the authenticated user from response
      final user = response.user;
      if (user == null) {
        throw const ServerException('Login failed: No user returned from API');
      }

      // Return UserModel created from Supabase user
      return UserModel.fromSupabaseUser(user);
    } on AppAuthException {
      // Re-throw our validation exceptions
      rethrow;
    } on supabase_auth.AuthException catch (e, stackTrace) {
      // ============ DEBUG: LOG RAW SUPABASE ERROR ============
      debugPrint('[AUTH_DEBUG] ❌ RAW SUPABASE AuthException in signIn():');
      debugPrint('[AUTH_DEBUG]   - message: ${e.message}');
      debugPrint('[AUTH_DEBUG]   - statusCode: ${e.statusCode}');
      debugPrint('[AUTH_DEBUG]   - stackTrace: $stackTrace');
      // ========================================================

      // Rethrow original Supabase error for easier debugging
      rethrow;
    } catch (e, stackTrace) {
      // ============ DEBUG: LOG RAW GENERAL ERROR ============
      debugPrint('[AUTH_DEBUG] ❌ RAW GENERAL Exception in signIn():');
      debugPrint('[AUTH_DEBUG]   - type: ${e.runtimeType}');
      debugPrint('[AUTH_DEBUG]   - message: $e');
      debugPrint('[AUTH_DEBUG]   - stackTrace: $stackTrace');
      // ========================================================

      // Rethrow original error
      rethrow;
    }
  }

  /// Sign out the currently authenticated user
  ///
  /// Clears the current session from Supabase.
  /// Throws [ServerException] if sign out fails.
  ///
  /// Returns: void on success
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      throw ServerException.fromError(e);
    }
  }

  /// Get the currently authenticated user
  ///
  /// Returns null if no user is currently logged in.
  /// Does not throw for unauthenticated state.
  UserModel? getCurrentUser() {
    final user = _client.auth.currentUser;
    return user != null ? UserModel.fromSupabaseUser(user) : null;
  }

  /// Stream of authentication state changes
  ///
  /// Emits events when:
  /// - Initial session is loaded
  /// - User signs in
  /// - User signs out
  /// - Token is refreshed
  /// - User profile is updated
  ///
  /// Returns: [Stream] of [User?] where null means unauthenticated
  Stream<supabase_auth.User?> authStateChanges() {
    return _client.auth.onAuthStateChange.map((data) {
      // Return the current user if authenticated, null otherwise
      return data.session?.user;
    });
  }

  /// Reset password for a user by email
  ///
  /// Sends a password reset email to the user's email address.
  /// Throws [AppAuthException] for invalid email format.
  /// Throws [ServerException] for API failures.
  ///
  /// Parameters:
  /// - [email]: User's email address to send reset to
  ///
  /// Returns: void on success
  Future<void> resetPassword({required String email}) async {
    _validateEmail(email);

    try {
      await _client.auth.resetPasswordForEmail(email);
    } on AppAuthException {
      rethrow;
    } on supabase_auth.AuthException catch (e, stackTrace) {
      // ============ DEBUG: LOG RAW SUPABASE ERROR ============
      debugPrint('[AUTH_DEBUG] ❌ RAW SUPABASE AuthException in resetPassword():');
      debugPrint('[AUTH_DEBUG]   - message: ${e.message}');
      debugPrint('[AUTH_DEBUG]   - statusCode: ${e.statusCode}');
      debugPrint('[AUTH_DEBUG]   - stackTrace: $stackTrace');
      // ========================================================

      throw ServerException('Supabase Auth Error: ${e.message} (code: ${e.statusCode})');
    } catch (e, stackTrace) {
      // ============ DEBUG: LOG RAW GENERAL ERROR ============
      debugPrint('[AUTH_DEBUG] ❌ RAW GENERAL Exception in resetPassword():');
      debugPrint('[AUTH_DEBUG]   - type: ${e.runtimeType}');
      debugPrint('[AUTH_DEBUG]   - message: $e');
      debugPrint('[AUTH_DEBUG]   - stackTrace: $stackTrace');
      // ========================================================

      throw ServerException.fromError(e);
    }
  }

  /// Validate email format
  ///
  /// Throws [AuthException] with code 'invalid_email' if invalid.
  void _validateEmail(String email) {
    // Simple email format validation
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (!emailRegex.hasMatch(email)) {
      throw const AppAuthException(
        'Invalid email format',
        code: 'invalid_email',
      );
    }
  }

  /// Validate password strength
  ///
  /// Throws [AppAuthException] with code 'weak_password' if invalid.
  void _validatePassword(String password) {
    // Minimum length check
    if (password.length < 6) {
      throw const AppAuthException(
        'Password must be at least 6 characters',
        code: 'weak_password',
      );
    }

    // Check for common weak passwords
    final weakPasswords = ['123456', 'password', 'qwerty'];
    if (weakPasswords.contains(password.toLowerCase())) {
      throw const AppAuthException(
        'Password is too common. Please choose a stronger password.',
        code: 'weak_password',
      );
    }
  }
}
