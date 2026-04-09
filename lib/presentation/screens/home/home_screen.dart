import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/presentation/screens/analytics/analytics_screen.dart';
import 'package:expense_tracker/presentation/screens/home/screens/settings_placeholder_screen.dart';
import 'package:expense_tracker/presentation/screens/transactions/transactions_list_screen.dart';
import 'package:expense_tracker/presentation/widgets/navigation/app_bottom_navigation.dart';
import 'package:expense_tracker/presentation/widgets/add_transaction_fab.dart';
import 'package:flutter/material.dart';

/// Home screen with bottom navigation.
///
/// Serves as the main entry point for authenticated users.
/// Uses IndexedStack to preserve state across tabs:
/// - Scroll positions are maintained
/// - Filters remain active
/// - Loaded data persists
///
/// FAB is only visible on Transactions tab (index 0).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      TransactionsListScreen(key: transactionsListScreenKey),
      const AnalyticsScreen(),
      const SettingsPlaceholderScreen(),
    ];
  }

  void _onDestinationSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: _currentIndex,
        onDestinationSelected: _onDestinationSelected,
      ),
      floatingActionButton: _currentIndex == 0
          ? AddTransactionFAB(
              onPressed: () => _handleAddTransaction(context),
            )
          : null,
    );
  }

  Future<void> _handleAddTransaction(BuildContext context) async {
    // Trigger the add transaction action on TransactionsListScreen
    final transactionsScreenKey = transactionsListScreenKey;
    transactionsScreenKey.currentState?.triggerAddTransaction(context);
  }
}
