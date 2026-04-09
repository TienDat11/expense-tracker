// Dart SDK
import 'dart:async';

// Packages
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Project

/// Environment configuration loader
///
/// Handles loading and accessing environment variables from .env file.
/// Must call [initialize] before accessing any environment values.
class Env {
  // Private constructor for singleton behavior
  Env._();

  /// Initialize environment variables from .env file
  ///
  /// Must be called before app starts. Returns true if successful,
  /// throws an exception if .env file is missing or required variables are not found.
  static Future<bool> initialize() async {
    try {
      await dotenv.load(fileName: '.env');
      // Verify required variables exist
      _verifyRequiredVariables();
      return true;
    } catch (e) {
      throw Exception('Failed to load environment variables: $e');
    }
  }

  /// Supabase project URL
  ///
  /// Used to initialize Supabase client connection.
  static String get supabaseUrl {
    final url = dotenv.env['SUPABASE_URL'];
    if (url == null || url.isEmpty) {
      throw const EnvironmentException('SUPABASE_URL is not set in .env file');
    }
    return url;
  }

  /// Supabase anonymous key
  ///
  /// Public API key for client-side access. Safe to include in client code.
  static String get supabaseAnonKey {
    final key = dotenv.env['SUPABASE_ANON_KEY'];
    if (key == null || key.isEmpty) {
      throw const EnvironmentException('SUPABASE_ANON_KEY is not set in .env file');
    }
    return key;
  }

  /// GLM 4 API key for AI insights
  ///
  /// Private API key for GLM 4 integration.
  static String get glmApiKey {
    final key = dotenv.env['GLM_API_KEY'];
    if (key == null || key.isEmpty) {
      throw const EnvironmentException('GLM_API_KEY is not set in .env file');
    }
    return key;
  }

  /// GLM API endpoint URL
  ///
  /// Default endpoint for GLM 4 API.
  static String get glmApiUrl =>
      dotenv.env['GLM_API_URL'] ?? 'https://open.bigmodel.cn/api/paas/v4/chat/completions';

  /// Verify all required environment variables are present
  ///
  /// Throws [EnvironmentException] if any required variable is missing.
  static void _verifyRequiredVariables() {
    final required = ['SUPABASE_URL', 'SUPABASE_ANON_KEY', 'GLM_API_KEY'];
    final missing = required.where((key) => dotenv.env[key]?.isEmpty ?? true).toList();

    if (missing.isNotEmpty) {
      throw EnvironmentException(
        'Missing required environment variables: ${missing.join(', ')}',
      );
    }
  }
}

/// Exception thrown when environment configuration is invalid
///
/// Used to indicate missing or malformed environment variables.
class EnvironmentException implements Exception {
  /// Human-readable error message
  final String message;

  const EnvironmentException(this.message);

  @override
  String toString() => 'EnvironmentException: $message';
}
