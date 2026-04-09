// Dart SDK
import 'dart:async';

// Packages
import 'package:supabase_flutter/supabase_flutter.dart';

// Project
import 'package:expense_tracker/core/config/env.dart';
import 'package:expense_tracker/core/exceptions/server_exception.dart';

/// Supabase service singleton
///
/// Manages Supabase client initialization and provides access to
/// authentication state and database operations. Ensures a single
/// instance of the Supabase client throughout the app.
///
/// Usage:
/// ```dart
/// await SupabaseService.initialize();
/// final client = SupabaseService.instance.client;
/// final user = SupabaseService.instance.currentUser;
/// ```
class SupabaseService {
  // Private constructor to enforce singleton pattern
  SupabaseService._();

  /// Singleton instance
  static final SupabaseService _instance = SupabaseService._();

  /// Access the singleton instance
  static SupabaseService get instance => _instance;

  /// Internal Supabase client instance
  ///
  /// Lazy initialized when first accessed via [client] getter.
  SupabaseClient? _client;

  /// Flag indicating if service has been initialized
  bool _isInitialized = false;

  /// Get the Supabase client
  ///
  /// Throws [StateError] if called before [initialize].
  SupabaseClient get client {
    if (!_isInitialized || _client == null) {
      throw StateError(
        'SupabaseService must be initialized before accessing client. '
        'Call SupabaseService.initialize() first.',
      );
    }
    return _client!;
  }

  /// Get the currently authenticated user
  ///
  /// Returns null if no user is currently logged in.
  User? get currentUser => client.auth.currentUser;

  /// Initialize Supabase client with environment variables
  ///
  /// Must be called once before app starts, typically in main():
  /// ```dart
  /// void main() async {
  ///   await SupabaseService.initialize();
  ///   runApp(MyApp());
  /// }
  /// ```
  ///
  /// Loads environment variables from .env and configures Supabase.
  /// Throws [EnvironmentException] if .env is missing or invalid.
  /// Throws [ServerException] if Supabase initialization fails.
  static Future<void> initialize() async {
    // Prevent duplicate initialization
    if (_instance._isInitialized) {
      return;
    }

    try {
      // Load environment variables first
      await Env.initialize();

      // Initialize Supabase with loaded credentials
      await Supabase.initialize(
        url: Env.supabaseUrl,
        anonKey: Env.supabaseAnonKey,
        debug: true, // Enable debug logging for development
      );

      // Store client reference and mark as initialized
      _instance._client = Supabase.instance.client;
      _instance._isInitialized = true;
    } catch (e) {
      // Convert environment errors to ServerException
      if (e is! ServerException) {
        throw ServerException.fromError(e);
      }
      rethrow;
    }
  }

  /// Stream of authentication state changes
  ///
  /// Emits:
  /// - [AuthChangeEvent.initialSession] on startup
  /// - [AuthChangeEvent.signedIn] when user logs in
  /// - [AuthChangeEvent.signedOut] when user logs out
  /// - [AuthChangeEvent.tokenRefreshed] when session is refreshed
  /// - [AuthChangeEvent.userUpdated] when user profile changes
  ///
  /// Usage:
  /// ```dart
  /// SupabaseService.instance.authStateChanges().listen((data) {
  ///   final event = data.event;
  ///   final session = data.session;
  ///   // Handle auth state changes
  /// });
  /// ```
  Stream<AuthState> authStateChanges() {
    return client.auth.onAuthStateChange;
  }

  /// Get the current session
  ///
  /// Returns null if no active session exists.
  Session? get currentSession => client.auth.currentSession;

  /// Check if a user is currently authenticated
  ///
  /// Returns true if a valid session exists, false otherwise.
  bool get isAuthenticated => currentSession != null;

  /// Sign out the current user
  ///
  /// Clears the local session and revokes the refresh token.
  /// Use this method for logout functionality.
  ///
  /// Throws [ServerException] if sign out fails.
  Future<void> signOut() async {
    try {
      await client.auth.signOut();
    } catch (e) {
      throw ServerException.fromError(e);
    }
  }

  /// Refresh the current session
  ///
  /// Forces a refresh of the access token using the refresh token.
  /// Useful when implementing token refresh logic manually.
  ///
  /// Returns the refreshed session.
  /// Throws [ServerException] if refresh fails.
  Future<Session> refreshSession() async {
    try {
      final response = await client.auth.refreshSession();
      return response.session!;
    } catch (e) {
      throw ServerException.fromError(e);
    }
  }

  /// Update the current user's metadata
  ///
  /// Updates user profile data stored in auth.user_metadata.
  ///
  /// Parameters:
  /// - [metadata]: Map of key-value pairs to update
  ///
  /// Returns the updated user object.
  /// Throws [ServerException] if update fails.
  Future<User> updateUserMetadata(Map<String, dynamic> metadata) async {
    try {
      final response = await client.auth.updateUser(
        UserAttributes(data: metadata),
      );
      return response.user!;
    } catch (e) {
      throw ServerException.fromError(e);
    }
  }

  /// Reset password for current user
  ///
  /// Sends a password reset email to the user's email address.
  ///
  /// Parameters:
  /// - [email]: User's email address
  ///
  /// Throws [ServerException] if request fails.
  Future<void> resetPassword(String email) async {
    try {
      await client.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw ServerException.fromError(e);
    }
  }

  /// Dispose of resources
  ///
  /// Currently a no-op as SupabaseFlutter manages its own lifecycle.
  /// Included for potential future cleanup needs.
  void dispose() {
    _client = null;
    _isInitialized = false;
  }
}
