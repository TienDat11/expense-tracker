import 'package:expense_tracker/data/models/transaction_model.dart';
import 'package:expense_tracker/data/models/transaction_type.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Date range filter options for transaction filtering.
enum DateRangeFilter {
  /// Show all transactions regardless of date
  all,

  /// Show transactions from today only
  today,

  /// Show transactions from this week (Sunday to Saturday)
  thisWeek,

  /// Show transactions from this month
  thisMonth,

  /// Show transactions within custom date range
  custom,
}

/// Provider for transaction filter state management.
///
/// Manages filtering by date range and transaction type.
/// All filtering logic lives in this provider, UI only reacts to state.
final transactionFilterProvider =
    NotifierProvider<TransactionFilterNotifier, TransactionFilterState>(
  TransactionFilterNotifier.new,
);

/// State class for transaction filters.
///
/// Immutable state containing all filter criteria.
/// Use copyWith for updating state while maintaining immutability.
class TransactionFilterState {
  /// Current date range filter
  final DateRangeFilter dateRange;

  /// Start date for custom range filter (null if not applicable)
  final DateTime? customStartDate;

  /// End date for custom range filter (null if not applicable)
  final DateTime? customEndDate;

  /// Transaction type filter (null = show all)
  final TransactionType? type;

  const TransactionFilterState({
    this.dateRange = DateRangeFilter.all,
    this.customStartDate,
    this.customEndDate,
    this.type,
  });

  /// Creates a copy with optional field replacements.
  ///
  /// Enables immutable updates without modifying original instance.
  TransactionFilterState copyWith({
    DateRangeFilter? dateRange,
    DateTime? customStartDate,
    DateTime? customEndDate,
    TransactionType? type,
    bool clearType = false,
  }) {
    return TransactionFilterState(
      dateRange: dateRange ?? this.dateRange,
      customStartDate: customStartDate ?? this.customStartDate,
      customEndDate: customEndDate ?? this.customEndDate,
      type: clearType ? null : (type ?? this.type),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransactionFilterState &&
        other.dateRange == dateRange &&
        other.customStartDate == customStartDate &&
        other.customEndDate == customEndDate &&
        other.type == type;
  }

  @override
  int get hashCode {
    return Object.hash(dateRange, customStartDate, customEndDate, type);
  }
}

/// Notifier for managing transaction filter state.
///
/// Provides methods to update filter criteria.
/// Applies filters and grouping to transaction data.
class TransactionFilterNotifier extends Notifier<TransactionFilterState> {
  @override
  TransactionFilterState build() {
    return const TransactionFilterState();
  }

  /// Sets date range filter.
  ///
  /// Resets custom dates when switching from custom range.
  void setDateRange(DateRangeFilter dateRange) {
    state = state.copyWith(
      dateRange: dateRange,
      customStartDate: dateRange != DateRangeFilter.custom ? null : null,
      customEndDate: dateRange != DateRangeFilter.custom ? null : null,
    );
  }

  /// Sets custom date range.
  ///
  /// Automatically sets dateRangeFilter to custom.
  void setCustomDateRange(DateTime startDate, DateTime endDate) {
    // Ensure end date is after start date
    final adjustedStart = startDate.isBefore(endDate) ? startDate : endDate;
    final adjustedEnd = endDate.isAfter(startDate) ? endDate : startDate;

    state = state.copyWith(
      dateRange: DateRangeFilter.custom,
      customStartDate: adjustedStart,
      customEndDate: adjustedEnd,
    );
  }

  /// Sets transaction type filter.
  ///
  /// Pass null to show all transaction types.
  void setType(TransactionType? type) {
    state = state.copyWith(type: type);
  }

  /// Resets all filters to default state.
  void reset() {
    state = const TransactionFilterState();
  }

  /// Gets date range start for current filter.
  ///
  /// Returns null if dateRange is 'all'.
  DateTime? getStartDate() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (state.dateRange) {
      case DateRangeFilter.all:
        return null;
      case DateRangeFilter.today:
        return today;
      case DateRangeFilter.thisWeek:
        // Start of week (Sunday)
        final dayOfWeek = today.weekday;
        final startOfWeek = today.subtract(Duration(days: dayOfWeek));
        return startOfWeek;
      case DateRangeFilter.thisMonth:
        return DateTime(now.year, now.month, 1);
      case DateRangeFilter.custom:
        return state.customStartDate;
    }
  }

  /// Gets date range end for current filter.
  ///
  /// Returns null if dateRange is 'all'.
  DateTime? getEndDate() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (state.dateRange) {
      case DateRangeFilter.all:
        return null;
      case DateRangeFilter.today:
        return DateTime(now.year, now.month, now.day, 23, 59, 59);
      case DateRangeFilter.thisWeek:
        // End of week (Saturday)
        final dayOfWeek = today.weekday;
        final endOfWeek = today.add(Duration(days: 6 - dayOfWeek));
        return DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day, 23, 59, 59);
      case DateRangeFilter.thisMonth:
        final lastDay = DateTime(now.year, now.month + 1, 0);
        return DateTime(lastDay.year, lastDay.month, lastDay.day, 23, 59, 59);
      case DateRangeFilter.custom:
        return state.customEndDate;
    }
  }

  /// Applies current filters to transaction list.
  ///
  /// Returns filtered list matching all active criteria.
  List<TransactionModel> applyFilters(List<TransactionModel> transactions) {
    final startDate = getStartDate();
    final endDate = getEndDate();

    return transactions.where((transaction) {
      // Filter by date range
      if (startDate != null) {
        final transactionDate = transaction.transactionDate;
        final normalizedDate = DateTime(
          transactionDate.year,
          transactionDate.month,
          transactionDate.day,
        );

        if (normalizedDate.isBefore(DateTime(startDate.year, startDate.month, startDate.day))) {
          return false;
        }
      }

      if (endDate != null) {
        final transactionDate = transaction.transactionDate;
        final normalizedDate = DateTime(
          transactionDate.year,
          transactionDate.month,
          transactionDate.day,
          transactionDate.hour,
          transactionDate.minute,
          transactionDate.second,
        );

        if (normalizedDate.isAfter(endDate)) {
          return false;
        }
      }

      // Filter by type
      if (state.type != null && transaction.type != state.type) {
        return false;
      }

      return true;
    }).toList();
  }

  /// Groups transactions by date with formatted labels.
  ///
  /// Returns map where keys are formatted date labels and values are transaction lists.
  /// Groups are sorted in descending chronological order.
  Map<String, List<TransactionModel>> groupTransactionsByDate(
    List<TransactionModel> transactions,
  ) {
    final Map<String, List<TransactionModel>> grouped = {};

    for (final transaction in transactions) {
      final dateKey = _formatDateLabel(transaction.transactionDate);

      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(transaction);
    }

    // Sort transactions within each group by transaction date (newest first)
    for (final key in grouped.keys) {
      grouped[key]!.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
    }

    return grouped;
  }

  /// Formats date as user-friendly label.
  ///
  /// Returns "Hôm nay", "Hôm qua", or formatted date.
  String _formatDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final transactionDay = DateTime(date.year, date.month, date.day);

    final difference = today.difference(transactionDay).inDays;

    if (difference == 0) return 'Hôm nay';
    if (difference == 1) return 'Hôm qua';

    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  /// Gets sorted list of date labels from grouped transactions.
  ///
  /// Returns labels in descending chronological order.
  List<String> getSortedDateLabels(Map<String, List<TransactionModel>> grouped) {
    return grouped.keys.toList()..sort((a, b) {
      // Sort by the latest transaction date in each group
      final aLatest = grouped[a]!.first.transactionDate;
      final bLatest = grouped[b]!.first.transactionDate;
      return bLatest.compareTo(aLatest);
    });
  }
}
