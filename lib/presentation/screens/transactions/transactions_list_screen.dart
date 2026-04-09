import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/data/models/category_model.dart' as models;
import 'package:expense_tracker/data/models/transaction_model.dart';
import 'package:expense_tracker/presentation/feedback/app_dialog.dart';
import 'package:expense_tracker/presentation/feedback/app_toast.dart';
import 'package:expense_tracker/presentation/providers/auth_provider.dart';
import 'package:expense_tracker/presentation/providers/category_provider.dart';
import 'package:expense_tracker/presentation/providers/transaction_filter_provider.dart';
import 'package:expense_tracker/presentation/providers/transaction_provider.dart';
import 'package:expense_tracker/presentation/screens/transactions/transaction_form_screen.dart';
// FAB import removed - now managed by HomeScreen
import 'package:expense_tracker/presentation/widgets/analytics/monthly_summary_card.dart';
import 'package:expense_tracker/presentation/widgets/transaction_detail_sheet.dart';
import 'package:expense_tracker/presentation/widgets/transaction_empty_state.dart';
import 'package:expense_tracker/presentation/widgets/transaction_group_header.dart';
import 'package:expense_tracker/presentation/widgets/transaction_list_item.dart';
import 'package:expense_tracker/presentation/widgets/transaction_time_filter_bar.dart';
import 'package:expense_tracker/presentation/widgets/transaction_type_filter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Global key for accessing TransactionsListScreen from HomeScreen.
///
/// Allows HomeScreen to trigger add transaction action when FAB is pressed.
final transactionsListScreenKey = GlobalKey<_TransactionsListScreenState>();

/// Screen displaying list of user transactions.
///
/// Supports loading, error, empty, and data states.
/// Features pull-to-refresh, swipe-to-delete, edit on tap.
/// Includes filtering by date range and transaction type.
/// Groups transactions by date with clear headers.
/// Clean, premium UI consistent with purple theme.
///
/// Note: FAB is now managed by HomeScreen. The [key] parameter is required
/// to allow HomeScreen to access the screen's add transaction method.
class TransactionsListScreen extends ConsumerStatefulWidget {
  const TransactionsListScreen({super.key});

  @override
  ConsumerState<TransactionsListScreen> createState() =>
      _TransactionsListScreenState();
}

class _TransactionsListScreenState
    extends ConsumerState<TransactionsListScreen> {
  /// Public method to trigger add transaction action.
  ///
  /// Called by HomeScreen when FAB is pressed.
  Future<void> triggerAddTransaction(BuildContext context) async {
    await _handleAddTransaction(context);
  }

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionProvider);
    final categoriesAsync = ref.watch(categoryProvider);
    final filterState = ref.watch(transactionFilterProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context, filterState),
      body: transactionsAsync.when(
        loading: () => _buildLoadingState(context),
        error: (error, stack) => _buildErrorState(context, error),
        data: (transactions) => _buildContent(
          context,
          transactions,
          categoriesAsync.valueOrNull ?? [],
          filterState,
        ),
      ),
    );
  }

  /// Builds app bar with title, reset filter button, and logout action.
  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    TransactionFilterState filterState,
  ) {
    final hasActiveFilter = filterState.dateRange != DateRangeFilter.all ||
        filterState.type != null;

    final theme = Theme.of(context);

    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      title: Text(
        'Giao dịch',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),
      ),
      actions: [
        // Logout button (always visible, subtle)
        IconButton(
          onPressed: () => _handleLogout(context),
          icon: const Icon(Icons.logout_rounded),
          iconSize: 22,
          tooltip: 'Đăng xuất',
          style: IconButton.styleFrom(
            foregroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        // Reset filter button (only when filter is active)
        if (hasActiveFilter)
          TextButton.icon(
            onPressed: () {
              ref.read(transactionFilterProvider.notifier).reset();
              AppToast.success(context, 'Đã xóa bộ lọc');
            },
            icon: const Icon(Icons.filter_alt_off_rounded, size: 20),
            label: const Text(
              'Xóa lọc',
              style: TextStyle(fontSize: 14),
            ),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
            ),
          ),
      ],
    );
  }

  /// Builds loading state with centered indicator.
  Widget _buildLoadingState(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.primary,
        strokeWidth: 3,
      ),
    );
  }

  /// Builds error state with retry option.
  Widget _buildErrorState(BuildContext context, Object error) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Không thể tải giao dịch',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _handleRefresh(context),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds main content with filters, grouping, and refresh capability.
  ///
  /// Uses CustomScrollView with Slivers to fix RefreshIndicator layout issue.
  /// RefreshIndicator now wraps the scrollable CustomScrollView directly.
  Widget _buildContent(
    BuildContext context,
    List<TransactionModel> transactions,
    List<models.CategoryModel> categories,
    TransactionFilterState filterState,
  ) {
    // Apply filters in provider layer
    final filteredTransactions =
        ref.read(transactionFilterProvider.notifier).applyFilters(transactions);

    // Group by date
    final groupedTransactions =
        ref.read(transactionFilterProvider.notifier).groupTransactionsByDate(
              filteredTransactions,
            );
    final sortedLabels =
        ref.read(transactionFilterProvider.notifier).getSortedDateLabels(
              groupedTransactions,
            );

    // Determine if user has any transactions at all
    final hasAnyTransactions = transactions.isNotEmpty;

    if (filteredTransactions.isEmpty) {
      return _buildEmptyState(context, filterState, hasAnyTransactions);
    }

    return RefreshIndicator(
      onRefresh: () => _handleRefresh(context),
      color: AppColors.primary,
      backgroundColor: null,
      child: CustomScrollView(
        slivers: [
          // Monthly analytics summary card - always visible
          const SliverToBoxAdapter(
            child: MonthlySummaryCard(),
          ),
          // Primary filter: Time range - scrollable chips (requires explicit height)
          SliverToBoxAdapter(
            child: SizedBox(
              height: 65,
              child: TransactionTimeFilterBar(
                selected: filterState.dateRange,
                onChanged: (range) => ref
                    .read(transactionFilterProvider.notifier)
                    .setDateRange(range),
              ),
            ),
          ),
          // Secondary filter: Transaction type - lower visual weight
          SliverToBoxAdapter(
            child: TransactionTypeFilter(
              selected: filterState.type,
              onChanged: (type) =>
                  ref.read(transactionFilterProvider.notifier).setType(type),
            ),
          ),
          // Subtle divider
          SliverToBoxAdapter(
            child: Container(
              height: 1,
              color: AppColors.outline.withValues(alpha: 0.3),
            ),
          ),
          // Transaction groups as sliver list
          _buildTransactionSliverList(
            context,
            sortedLabels,
            groupedTransactions,
          ),
        ],
      ),
    );
  }

  /// Builds the transaction list using SliverList.
  ///
  /// Renders grouped transactions with date headers and items.
  Widget _buildTransactionSliverList(
    BuildContext context,
    List<String> sortedLabels,
    Map<String, List<TransactionModel>> groupedTransactions,
  ) {
    return SliverPadding(
      padding: const EdgeInsets.only(bottom: 100),
      sliver: SliverList.builder(
        itemBuilder: (context, index) {
          final label = sortedLabels[index];
          final groupTransactions = groupedTransactions[label]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: TransactionGroupHeader(
                  label: label,
                  count: groupTransactions.length,
                ),
              ),
              const SizedBox(height: 8),
              ...groupTransactions.map((transaction) {
                final category = ref
                    .read(categoryProvider.notifier)
                    .getById(transaction.categoryId);

                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: _buildDismissibleItem(
                    context,
                    transaction,
                    category,
                  ),
                );
              }),
            ],
          );
        },
        itemCount: sortedLabels.length,
      ),
    );
  }

  /// Builds empty state with illustration and CTA.
  ///
  /// Uses CustomScrollView with SliverFillRemaining for proper layout.
  /// Determines which variant to show based on state.
  Widget _buildEmptyState(
    BuildContext context,
    TransactionFilterState filterState,
    bool hasAnyTransactions,
  ) {
    final hasActiveFilter = filterState.dateRange != DateRangeFilter.all ||
        filterState.type != null;

    // Choose variant based on state
    // - First-time: no transactions at all
    // - Filtered: has transactions but filters hide them
    final isFirstTime = !hasAnyTransactions;

    return RefreshIndicator(
      onRefresh: () => _handleRefresh(context),
      color: AppColors.primary,
      backgroundColor: null,
      child: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: TransactionEmptyState(
              variant: isFirstTime
                  ? EmptyStateVariant.firstTime
                  : EmptyStateVariant.filtered,
              onPrimaryAction:
                  isFirstTime ? () => _handleAddTransaction(context) : null,
              onSecondaryAction: hasActiveFilter
                  ? () {
                      ref.read(transactionFilterProvider.notifier).reset();
                      AppToast.success(context, 'Đã xóa bộ lọc');
                    }
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds dismissible item with swipe-to-delete.
  Widget _buildDismissibleItem(
    BuildContext context,
    TransactionModel transaction,
    models.CategoryModel? category,
  ) {
    return Dismissible(
      key: Key(transaction.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          return await _showDeleteConfirmation(context);
        }
        return false;
      },
      onDismissed: (_) => _handleDelete(context, transaction),
      background: _buildSwipeBackground(),
      child: TransactionListItem(
        transaction: transaction,
        category: category,
        onTap: () => _handlePreview(context, transaction, category),
      ),
    );
  }

  /// Handles transaction preview (opens bottom sheet).
  Future<void> _handlePreview(
    BuildContext context,
    TransactionModel transaction,
    models.CategoryModel? category,
  ) async {
    if (!mounted) return;

    await TransactionDetailSheet.show(
      context,
      transaction: transaction,
      category: category,
    );
  }

  /// Builds swipe-to-delete background.
  Widget _buildSwipeBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 24),
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.delete_rounded,
        color: Colors.white,
        size: 28,
      ),
    );
  }

  /// Shows delete confirmation dialog using AppDialog.
  ///
  /// Returns true if user confirms deletion, false otherwise.
  Future<bool?> _showDeleteConfirmation(BuildContext context) async {
    return AppDialog.confirmDestructive(
      context,
      title: 'Xóa giao dịch',
      content: 'Bạn có chắc muốn xóa giao dịch này không?',
    );
  }

  /// Handles refresh action.
  Future<void> _handleRefresh(BuildContext context) async {
    await ref.read(transactionProvider.notifier).refresh();
  }

  /// Handles add transaction action.
  Future<void> _handleAddTransaction(BuildContext context) async {
    if (!mounted) return;

    final result = await showTransactionForm(context);
    if (!mounted) return;

    if (result == true) {
      // ignore: use_build_context_synchronously
      AppToast.success(context, 'Đã thêm giao dịch');
    }
  }

  /// Handles delete transaction action.
  Future<void> _handleDelete(
    BuildContext context,
    TransactionModel transaction,
  ) async {
    if (!mounted) return;

    try {
      await ref
          .read(transactionProvider.notifier)
          .deleteTransaction(transaction.id);
      if (!mounted) return;
      // ignore: use_build_context_synchronously
      AppToast.success(context, 'Đã xóa giao dịch');
    } catch (e) {
      if (!mounted) return;
      // ignore: use_build_context_synchronously
      AppToast.error(context, 'Không thể xóa giao dịch');
    }
  }

  /// Handles logout action.
  ///
  /// Shows confirmation dialog, calls AuthProvider.signOut(),
  /// and displays success toast. AuthGate handles navigation.
  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await AppDialog.confirmDestructive(
      context,
      isLogout: true,
      title: 'Đăng xuất',
      content: 'Bạn có chắc muốn đăng xuất không?',
    );

    if (confirmed != true) return;

    await ref.read(authProvider.notifier).signOut();

    if (!mounted) return;
    // ignore: use_build_context_synchronously
    AppToast.success(context, 'Đã đăng xuất');
  }
}
