// Flutter
import 'package:flutter/material.dart';

// Project
import 'package:expense_tracker/presentation/screens/splash/splash_screen.dart';
import 'package:expense_tracker/presentation/screens/auth/login_screen.dart';
import 'package:expense_tracker/presentation/screens/auth/register_screen.dart';
import 'package:expense_tracker/presentation/screens/home/home_screen.dart';

/// Application route names
///
/// Centralized constants for all app routes.
/// Using string constants instead of raw strings prevents typos.
class AppRoutes {
  // Auth routes
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';

  // Main app routes (to be implemented in future phases)
  static const String home = '/home';
  static const String transactions = '/transactions';
  static const String statistics = '/statistics';
  static const String aiInsights = '/ai-insights';

  AppRoutes._();
}

/// App router configuration
///
/// Defines all application routes and navigation logic.
/// Uses named routes with auth guards for access control.
class AppRouter {
  /// Route map for named navigation
  ///
  /// Maps route names to widget builders.
  /// Used with Navigator.pushNamed().
  static final Map<String, WidgetBuilder> routes = {
    AppRoutes.splash: (context) => const SplashScreen(),
    AppRoutes.login: (context) => const LoginScreen(),
    AppRoutes.register: (context) => const RegisterScreen(),

    // Home screen with bottom navigation for authenticated users
    AppRoutes.home: (context) => const HomeScreen(),

    // TODO: Add routes for statistics, ai_insights (if needed)
    // Transactions and Analytics are now accessed via HomeScreen tabs
    // AppRoutes.statistics: (context) => const StatisticsScreen(),
    // AppRoutes.aiInsights: (context) => const AIInsightsScreen(),
  };
}
