import 'package:expense_tracker/data/models/transaction_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repository for managing transaction data from Supabase.
/// Implements repository pattern for separation of concerns.
/// Supports CRUD operations with realtime subscriptions.
class TransactionRepository {
  /// Supabase client for database operations.
  final SupabaseClient _supabase;

  /// Table name constant to avoid typos and enable easy refactoring.
  static const String _tableName = 'transactions';

  /// Constructor requires Supabase client for dependency injection.
  const TransactionRepository({
    required SupabaseClient supabase,
  }) : _supabase = supabase;

  /// Fetches transactions with pagination support.
  /// Joins categories table for complete transaction data.
  /// Orders by transaction_date descending for recent-first display.
  Future<List<TransactionModel>> fetchTransactions({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select('*, categories(*)')
          .order('transaction_date', ascending: false)
          .range(offset, offset + limit - 1);

      return (response as List)
          .map((json) => _parseTransactionWithCategory(json))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Inserts a new transaction into the database.
  /// Returns the created transaction with server-generated fields.
  Future<TransactionModel> insertTransaction(
      TransactionModel transaction) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .insert({
            'user_id': transaction.userId,
            'category_id': transaction.categoryId,
            'amount': transaction.amount,
            'type': transaction.type.name,
            'note': transaction.note,
            'transaction_date': transaction.transactionDate.toIso8601String(),
          })
          .select()
          .single();

      return _parseTransactionWithCategory(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Updates an existing transaction in the database.
  /// Uses transaction ID for identification.
  /// Returns updated transaction with new timestamp.
  Future<TransactionModel> updateTransaction(
      TransactionModel transaction) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .update({
            'category_id': transaction.categoryId,
            'amount': transaction.amount,
            'type': transaction.type.name,
            'note': transaction.note,
            'transaction_date': transaction.transactionDate.toIso8601String(),
          })
          .eq('id', transaction.id)
          .select()
          .single();

      return _parseTransactionWithCategory(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Deletes a transaction by its unique identifier.
  /// Uses RLS policy to ensure user can only delete their own transactions.
  Future<void> deleteTransaction(String transactionId) async {
    try {
      await _supabase.from(_tableName).delete().eq('id', transactionId);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Creates a realtime stream for transaction updates.
  /// Listens for INSERT, UPDATE, and DELETE events on user's transactions.
  /// Requires RLS policy to filter by user_id automatically.
  Stream<List<TransactionModel>> streamTransactions(String userId) {
    return _supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('transaction_date', ascending: false)
        .map((data) =>
            data.map((json) => _parseTransactionWithCategory(json)).toList());
  }

  /// Parses transaction data joined with category from Supabase response.
  /// Handles nested category object structure from joined query.
  TransactionModel _parseTransactionWithCategory(Map<String, dynamic> json) {
    return TransactionModel.fromJson(json);
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
