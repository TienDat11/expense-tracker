import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// Bottom navigation bar for HomeScreen.
///
/// Uses Material 3 NavigationBar with Material Design 3 specifications:
/// - Height: 60dp (handled by NavigationBar default)
/// - Icons: 24dp
/// - Label size: 12dp
/// - Active color: Primary
/// - Inactive color: Text secondary
/// - Surface color: colorScheme.surface
class AppBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  const AppBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  static const _destinations = [
    NavigationDestination(
      icon: Icon(Icons.receipt_long_rounded,
          color: AppColors.textSecondary, size: 24),
      selectedIcon:
          Icon(Icons.receipt_long_rounded, color: AppColors.primary, size: 24),
      label: 'Giao dịch',
    ),
    NavigationDestination(
      icon: Icon(Icons.pie_chart_rounded,
          color: AppColors.textSecondary, size: 24),
      selectedIcon:
          Icon(Icons.pie_chart_rounded, color: AppColors.primary, size: 24),
      label: 'Thống kê',
    ),
    NavigationDestination(
      icon: Icon(Icons.settings_rounded,
          color: AppColors.textSecondary, size: 24),
      selectedIcon:
          Icon(Icons.settings_rounded, color: AppColors.primary, size: 24),
      label: 'Cài đặt',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onDestinationSelected,
      height: 60,
      destinations: _destinations,
      backgroundColor: theme.colorScheme.surface,
      indicatorColor: AppColors.primary.withValues(alpha: 0.12),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      elevation: 0,
      animationDuration: const Duration(milliseconds: 200),
      overlayColor: const WidgetStatePropertyAll<Color>(Colors.transparent),
    );
  }
}
