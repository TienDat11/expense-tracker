import 'package:expense_tracker/data/models/transaction_model.dart';
import 'package:expense_tracker/data/models/transaction_type.dart';
import 'package:expense_tracker/presentation/providers/transaction_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for monthly analytics calculations.
///
/// Computes current month's income, expense, and balance
/// from transaction data. Reacts to transaction changes
/// and automatically updates calculations.
final monthlyAnalyticsProvider = Provider<MonthlyAnalytics>((ref) {
  final transactions = ref.watch(transactionProvider).valueOrNull ?? [];
  return MonthlyAnalytics.fromTransactions(transactions);
});

/// Immutable model holding monthly analytics data.
///
/// Contains computed values for current month's
/// income, expense, and net balance.
class MonthlyAnalytics {
  /// Total income for current month.
  final double income;

  /// Total expense for current month.
  final double expense;

  /// Net balance (income - expense).
  final double balance;

  const MonthlyAnalytics({
    required this.income,
    required this.expense,
    required this.balance,
  });

  /// Computes analytics from transaction list.
  ///
  /// Filters transactions to current month and
  /// calculates totals by type.
  factory MonthlyAnalytics.fromTransactions(List<TransactionModel> transactions) {
    final now = DateTime.now();
    final currentMonthStart = DateTime(now.year, now.month, 1);
    final nextMonthStart = DateTime(now.year, now.month + 1, 1);

    final currentMonthTransactions = transactions.where((t) {
      return t.transactionDate.isAtSameMomentAs(currentMonthStart) ||
          (t.transactionDate.isAfter(currentMonthStart) &&
              t.transactionDate.isBefore(nextMonthStart));
    }).toList();

    double totalIncome = 0;
    double totalExpense = 0;

    for (final transaction in currentMonthTransactions) {
      if (transaction.type == TransactionType.income) {
        totalIncome += transaction.amount;
      } else {
        totalExpense += transaction.amount;
      }
    }

    return MonthlyAnalytics(
      income: totalIncome,
      expense: totalExpense,
      balance: totalIncome - totalExpense,
    );
  }

  /// Creates a copy with optional field replacements.
  MonthlyAnalytics copyWith({
    double? income,
    double? expense,
    double? balance,
  }) {
    return MonthlyAnalytics(
      income: income ?? this.income,
      expense: expense ?? this.expense,
      balance: balance ?? this.balance,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MonthlyAnalytics &&
        other.income == income &&
        other.expense == expense &&
        other.balance == balance;
  }

  @override
  int get hashCode => Object.hash(income, expense, balance);
}
