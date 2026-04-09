import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/data/models/transaction_model.dart';
import 'package:expense_tracker/data/models/transaction_type.dart';
import 'package:expense_tracker/presentation/providers/analytics_insight_provider.dart';
import 'package:expense_tracker/presentation/providers/analytics_provider.dart';
import 'package:expense_tracker/presentation/providers/category_analytics_provider.dart';
import 'package:expense_tracker/presentation/providers/transaction_filter_provider.dart';
import 'package:expense_tracker/presentation/providers/transaction_provider.dart';
import 'package:expense_tracker/presentation/widgets/analytics/category_bar_chart.dart';
import 'package:expense_tracker/presentation/widgets/analytics/category_breakdown_list.dart';
import 'package:expense_tracker/presentation/widgets/analytics/monthly_summary_card.dart';
import 'package:expense_tracker/presentation/widgets/analytics/spending_pie_chart.dart';
import 'package:expense_tracker/presentation/widgets/analytics_insight_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Screen displaying financial analytics and charts.
///
/// Shows monthly summary, category breakdown donut chart,
/// category list, and category bar chart.
/// Supports switching between income and expense views.
class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(transactionFilterProvider);
    final selectedType = filterState.type ?? TransactionType.expense;
    final monthlyAnalytics = ref.watch(monthlyAnalyticsProvider);
    final insights = ref.watch(analyticsInsightProvider);
    final categoryStats = ref.watch(categoryAnalyticsProvider(
        selectedType == TransactionType.income
            ? AnalyticsType.income
            : AnalyticsType.expense));
    final transactionsAsync = ref.watch(transactionProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: transactionsAsync.when(
        loading: () => _buildLoadingState(context),
        error: (_, __) => _buildErrorState(context, ref),
        data: (transactions) => _buildContent(
          context,
          ref,
          monthlyAnalytics,
          insights,
          categoryStats,
          transactions,
          selectedType,
        ),
      ),
    );
  }

  /// Builds app bar with title and logout option.
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      title: Text(
        'Thống kê',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),
      ),
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
  Widget _buildErrorState(BuildContext context, WidgetRef ref) {
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
              'Không thể tải thống kê',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref.read(transactionProvider.notifier).refresh(),
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

  /// Builds main content with charts and lists.
  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    MonthlyAnalytics monthlyAnalytics,
    List<dynamic> insights,
    List<dynamic> categoryStats,
    List<TransactionModel> transactions,
    TransactionType selectedType,
  ) {
    final hasData = categoryStats.isNotEmpty;

    return CustomScrollView(
      slivers: [
        // Monthly summary card
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: MonthlySummaryCard(),
          ),
        ),
        // Insight cards
        if (insights.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: _buildInsightSection(context, insights),
            ),
          ),
        if (hasData) ...[
          // Transaction type toggle
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildTypeToggle(context, ref, selectedType),
            ),
          ),
          // Category breakdown donut chart
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: SpendingPieChart(
                categoryStats: categoryStats,
              ),
            ),
          ),
          // Category breakdown list
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: CategoryBreakdownList(
                categoryStats: categoryStats,
              ),
            ),
          ),
          // Category bar chart
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: CategoryBarChart(
                categoryStats: categoryStats,
              ),
            ),
          ),
        ],
        if (!hasData)
          SliverFillRemaining(
            hasScrollBody: false,
            child: _buildEmptyStateContent(context),
          ),
      ],
    );
  }

  /// Builds transaction type toggle for income/expense switch.
  Widget _buildTypeToggle(
    BuildContext context,
    WidgetRef ref,
    TransactionType selectedType,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SegmentedButton<TransactionType>(
        segments: const [
          ButtonSegment(
            value: TransactionType.expense,
            label: Text('Chi tiêu'),
            icon: Icon(Icons.trending_down, size: 18),
          ),
          ButtonSegment(
            value: TransactionType.income,
            label: Text('Thu nhập'),
            icon: Icon(Icons.trending_up, size: 18),
          ),
        ],
        selected: {selectedType},
        onSelectionChanged: (Set<TransactionType> newSelection) {
          // Safely extract first value from set
          final newType = newSelection.isNotEmpty
              ? newSelection.first
              : TransactionType.expense;
          // Update provider state
          ref.read(transactionFilterProvider.notifier).setType(newType);
        },
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.primary;
            }
            return Colors.transparent;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.white;
            }
            return AppColors.textSecondary;
          }),
        ),
      ),
    );
  }

  /// Builds empty state content when no data available.
  Widget _buildEmptyStateContent(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart,
            size: 80,
            color: AppColors.textSecondary.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 24),
          Text(
            'Chưa có dữ liệu thống kê',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            'Hãy thêm giao dịch để xem báo cáo',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Builds insight cards section with header.
  Widget _buildInsightSection(BuildContext context, List<dynamic> insights) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gợi ý chi tiêu',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 12),
        ...insights.map(
          (insight) => AnalyticsInsightCard(
            insight: insight as dynamic,
          ),
        ),
      ],
    );
  }
}
