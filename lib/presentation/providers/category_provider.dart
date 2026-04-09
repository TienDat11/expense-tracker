import 'package:expense_tracker/data/models/category_model.dart';
import 'package:expense_tracker/data/models/transaction_type.dart';
import 'package:expense_tracker/data/repositories/category_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider for category repository dependency injection.
/// Uses asyncValue to handle initialization errors gracefully.
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final supabase = Supabase.instance.client;
  return CategoryRepository(supabase: supabase);
});

/// AsyncNotifier provider for category state management.
/// Manages loading, error, and data states for categories.
/// Provides type-specific access to income and expense categories.
final categoryProvider =
    AsyncNotifierProvider<CategoryNotifier, List<CategoryModel>>(
  CategoryNotifier.new,
);

/// Notifier class for managing category state with Riverpod.
/// Implements AsyncNotifier for async data handling.
/// Caches categories for efficient type-based filtering.
class CategoryNotifier extends AsyncNotifier<List<CategoryModel>> {
  /// Reference to category repository for data operations.
  CategoryRepository get _repository => ref.read(categoryRepositoryProvider);

  @override
  Future<List<CategoryModel>> build() async {
    return await _repository.fetchAllCategories();
  }

  /// Returns income categories from loaded data.
  /// Filters cached categories by TransactionType.income.
  /// Returns empty list if categories haven't loaded yet.
  List<CategoryModel> get incomeCategories {
    return state.valueOrNull
            ?.where((category) => category.type == TransactionType.income)
            .toList() ??
        [];
  }

  /// Returns expense categories from loaded data.
  /// Filters cached categories by TransactionType.expense.
  /// Returns empty list if categories haven't loaded yet.
  List<CategoryModel> get expenseCategories {
    return state.valueOrNull
            ?.where((category) => category.type == TransactionType.expense)
            .toList() ??
        [];
  }

  /// Forces refresh of categories from database.
  /// Invalidates repository cache before fetching fresh data.
  /// Use this after creating or deleting categories.
  Future<void> refresh() async {
    ref.read(categoryRepositoryProvider).invalidateCache();
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.fetchAllCategories());
  }

  /// Finds a category by its unique identifier.
  /// Returns null if category not found or data not loaded.
  CategoryModel? getById(String id) {
    final categories = state.valueOrNull;
    if (categories == null) return null;

    for (final category in categories) {
      if (category.id == id) {
        return category;
      }
    }
    return null;
  }
}
