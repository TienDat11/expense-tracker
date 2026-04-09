import 'package:expense_tracker/data/models/category_model.dart';
import 'package:expense_tracker/data/models/transaction_type.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repository for managing category data from Supabase.
/// Provides caching to reduce database queries for static data.
/// Implements repository pattern for separation of concerns.
class CategoryRepository {
  /// Supabase client for database operations.
  final SupabaseClient _supabase;

  /// In-memory cache for categories to avoid redundant queries.
  /// Categories are static reference data, rarely change during session.
  final List<CategoryModel> _cache = [];

  /// Flag indicating if cache has been populated.
  /// Prevents unnecessary database hits when cache is valid.
  bool _isCacheValid = false;

  /// Table name constant to avoid typos and enable easy refactoring.
  static const String _tableName = 'categories';

  /// Constructor requires Supabase client for dependency injection.
  CategoryRepository({
    required SupabaseClient supabase,
  }) : _supabase = supabase;

  /// Fetches all categories from database or returns cached results.
  /// Categories are fetched once per session and cached for performance.
  /// Throws RepositoryException on database errors.
  Future<List<CategoryModel>> fetchAllCategories() async {
    if (_isCacheValid) {
      return List.unmodifiable(_cache);
    }

    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .order('created_at', ascending: true);

      final categories = (response as List)
          .map((json) => CategoryModel.fromJson(json as Map<String, dynamic>))
          .toList();

      _cache
        ..clear()
        ..addAll(categories);
      _isCacheValid = true;

      return List.unmodifiable(categories);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Fetches categories filtered by transaction type (income or expense).
  /// Uses cached data when available to minimize API calls.
  /// Returns empty list if no categories match the type.
  Future<List<CategoryModel>> fetchCategoriesByType(
      TransactionType type) async {
    final allCategories = await fetchAllCategories();

    final filtered =
        allCategories.where((category) => category.type == type).toList();

    return List.unmodifiable(filtered);
  }

  /// Invalidates cache forcing next fetch to query database.
  /// Use this after creating or deleting categories.
  /// Ensures data consistency when categories are modified.
  void invalidateCache() {
    _cache.clear();
    _isCacheValid = false;
  }

  /// Maps database errors to application exceptions.
  /// Provides user-friendly error messages for UI display.
  Exception _handleError(dynamic error) {
    if (error is PostgrestException) {
      return RepositoryException(
        message: error.message,
        code: 'DATABASE_ERROR',
      );
    }
    return RepositoryException(
      message: error.toString(),
      code: 'UNKNOWN_ERROR',
    );
  }
}

/// Custom exception for repository-level errors.
/// Wraps Supabase errors with additional context.
class RepositoryException implements Exception {
  /// User-friendly error message for display.
  final String message;

  /// Error code for programmatic handling.
  final String code;

  const RepositoryException({
    required this.message,
    required this.code,
  });

  @override
  String toString() => 'RepositoryException: $message (code: $code)';
}
