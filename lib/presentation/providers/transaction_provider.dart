import 'dart:async';

import 'package:expense_tracker/data/models/transaction_model.dart';
import 'package:expense_tracker/data/repositories/transaction_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

import 'auth_provider.dart';

/// Provider for transaction repository dependency injection.
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final supabase = Supabase.instance.client;
  return TransactionRepository(supabase: supabase);
});

/// AsyncNotifier provider for transaction state management.
///
/// Watches authProvider to rebuild when authentication state changes.
final transactionProvider =
    AsyncNotifierProvider<TransactionNotifier, List<TransactionModel>>(
  TransactionNotifier.new,
);

/// Notifier class for managing transaction state with Riverpod.
///
/// Combines initial fetch with realtime subscription for live updates.
class TransactionNotifier extends AsyncNotifier<List<TransactionModel>> {
  /// Reference to transaction repository for data operations.
  TransactionRepository get _repository =>
      ref.read(transactionRepositoryProvider);

  /// Reference to auth provider for tracking user ID changes.
  AuthState get _authState => ref.watch(authProvider);

  /// Pagination limit per request.
  static const int _pageSize = 50;

  /// Current offset for pagination tracking.
  int _currentOffset = 0;

  /// Tracks the previous user ID to detect account switches.
  String? _previousUserId;

  /// Stream subscription for realtime updates.
  StreamSubscription<List<TransactionModel>>? _streamSubscription;

  /// Listener for auth state changes to trigger refetch.
  ProviderSubscription<AuthState>? _authListener;

  @override
  Future<List<TransactionModel>> build() async {
    _listenToAuthChanges();

    final userId = _authState.user?.id;
    if (userId == null) {
      return [];
    }

    _previousUserId = userId;

    final transactions = await _repository.fetchTransactions(
      limit: _pageSize,
      offset: _currentOffset,
    );

    _currentOffset = _pageSize;

    _listenToRealtimeUpdates(userId);

    return transactions;
  }

  /// Listens to auth state changes and triggers rebuild when user changes.
  void _listenToAuthChanges() {
    _authListener?.close();

    _authListener = ref.listen(authProvider, (previous, next) {
      final nextUserId = next.user?.id;

      if (_previousUserId != nextUserId) {
        _previousUserId = nextUserId;

        if (nextUserId != null) {
          refresh();
        } else {
          _currentOffset = 0;
          state = const AsyncValue.data([]);
        }
      }
    });
  }

  /// Subscribes to realtime transaction updates.
  void _listenToRealtimeUpdates(String userId) {
    _streamSubscription?.cancel();

    _streamSubscription = _repository.streamTransactions(userId).listen(
      (updatedTransactions) {
        state = AsyncValue.data(updatedTransactions);
      },
      onError: (error) {
        state = AsyncValue.error(error, StackTrace.current);
      },
    );
  }

  /// Forces refresh of transactions from database.
  Future<void> refresh() async {
    _currentOffset = 0;

    final userId = _authState.user?.id;
    if (userId == null) {
      state = const AsyncValue.data([]);
      return;
    }

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final transactions = await _repository.fetchTransactions(
        limit: _pageSize,
        offset: 0,
      );
      _currentOffset = _pageSize;
      return transactions;
    });
  }

  /// Loads more transactions for pagination.
  Future<void> loadMore() async {
    if (state.isLoading || state.valueOrNull == null) {
      return;
    }

    final userId = _authState.user?.id;
    if (userId == null) {
      return;
    }

    final currentTransactions = state.valueOrNull ?? [];

    try {
      final newTransactions = await _repository.fetchTransactions(
        limit: _pageSize,
        offset: _currentOffset,
      );

      _currentOffset += _pageSize;

      state = AsyncValue.data([...currentTransactions, ...newTransactions]);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Adds a new transaction to the database.
  Future<void> addTransaction(TransactionModel transaction) async {
    final currentTransactions = state.valueOrNull ?? [];

    try {
      state = AsyncValue.data([...currentTransactions, transaction]);

      final created = await _repository.insertTransaction(transaction);

      state = AsyncValue.data([
        created,
        ...currentTransactions.where((t) => t.id != transaction.id),
      ]);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Updates an existing transaction in the database.
  Future<void> updateTransaction(TransactionModel transaction) async {
    final currentTransactions = state.valueOrNull ?? [];

    try {
      final updated = await _repository.updateTransaction(transaction);

      state = AsyncValue.data(
        currentTransactions
            .map((t) => t.id == transaction.id ? updated : t)
            .toList(),
      );
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Deletes a transaction from the database.
  Future<void> deleteTransaction(String transactionId) async {
    final currentTransactions = state.valueOrNull ?? [];

    try {
      state = AsyncValue.data(
        currentTransactions.where((t) => t.id != transactionId).toList(),
      );

      await _repository.deleteTransaction(transactionId);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
