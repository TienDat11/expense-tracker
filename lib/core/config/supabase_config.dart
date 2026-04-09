// Project
import 'package:expense_tracker/core/config/env.dart';

/// Supabase configuration constants
///
/// Centralizes all Supabase-related configuration values.
/// Provides easy access to project URL and tables for database operations.
class SupabaseConfig {
  // Private constructor to prevent instantiation
  SupabaseConfig._();

  /// Supabase project URL
  ///
  /// Loaded from environment variable for security and flexibility
  /// across development, staging, and production environments.
  static String get url => Env.supabaseUrl;

  /// Supabase anonymous key
  ///
  /// Public API key for client-side authentication.
  /// Safe to include in compiled code as it has limited permissions.
  static String get anonKey => Env.supabaseAnonKey;

  /// Database table name for transactions
  ///
  /// Used for all transaction-related queries and operations.
  static const String transactionsTable = 'transactions';

  /// Database table name for categories
  ///
  /// Used for fetching and filtering transaction categories.
  static const String categoriesTable = 'categories';

  /// Database table name for user profiles
  ///
  /// References the profiles table which extends auth.users.
  static const String profilesTable = 'profiles';

  /// Default pagination limit for database queries
  ///
  /// Balances between performance and data completeness.
  /// Can be overridden in individual queries.
  static const int defaultLimit = 50;

  /// Maximum allowed pagination limit
  ///
  /// Prevents excessive data fetching that could impact performance.
  static const int maxLimit = 100;

  /// Timeout duration for Supabase operations
  ///
  /// Used for network requests to prevent indefinite hanging.
  static const Duration timeout = Duration(seconds: 30);

  /// Enable debug mode for Supabase
  ///
  /// Logs detailed request/response information in development.
  /// Should be disabled in production builds.
  static bool get debugMode => const bool.fromEnvironment('DEBUG', defaultValue: true);
}
