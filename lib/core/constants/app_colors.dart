import 'package:flutter/material.dart';

/// Application color design tokens
///
/// Centralizes all color definitions for consistent theming.
/// Use these tokens instead of hardcoding colors anywhere in the codebase.
///
/// Design Strategy: 70/25/5 Rule
/// - 70% neutral backgrounds
/// - 25% white cards
/// - 5% purple accents
///
/// Brand: Calm purple (#7C6AEF) for daily-use comfort

class AppColors {
  AppColors._();

  /// Brand colors
  /// Primary brand color for main actions and emphasis
  /// Calmer purple (#7C6AEF) - reduced saturation for visual comfort
  static const Color primary = Color(0xFF7C6AEF);

  /// Muted primary for backgrounds and overlays
  /// Lighter purple with reduced intensity
  static const Color primaryMuted = Color(0xFF9B8FFF);

  /// Accent color for secondary CTAs and highlights
  /// Soft violet accent
  static const Color accent = Color(0xFF8B7CFF);

  /// Semantic colors
  /// Success color for positive indicators (income, success messages)
  /// Softer emerald green
  static const Color success = Color(0xFF10B981);

  /// Error color for errors and expenses
  /// Softer red
  static const Color error = Color(0xFFEF4444);

  /// Warning color for alerts and pending states
  /// Amber-orange
  static const Color warning = Color(0xFFF59E0B);

  /// Info color for insights and informational content
  /// Sky blue
  static const Color info = Color(0xFF0EA5E9);

  /// Neutral colors - Light Mode
  /// Background color for the app
  /// Neutral gray-white (replaces purple-tinted)
  static const Color background = Color(0xFFFAFAFA);

  /// Surface color for cards, sheets, and dialogs
  static const Color surface = Color(0xFFFFFFFF);

  /// Elevated surface for dialogs, modals, and bottom sheets
  static const Color surfaceElevated = Color(0xFFF8F9FA);

  /// Primary text color
  static const Color textPrimary = Color(0xFF1A1A1A);

  /// Secondary text color
  static const Color textSecondary = Color(0xFF757575);

  /// Outline color for borders and dividers
  static const Color outline = Color(0xFFE8E5F0);

  /// Soft outline for subtle borders
  static const Color outlineSoft = Color(0xFFF0EEF8);

  /// Subtle container for selected states, chips, and secondary backgrounds
  /// Lighter purple tint
  static const Color subtleContainer = Color(0xFFF0EEF8);

  /// Neutral colors - Dark Mode
  /// Background color for the app (dark mode)
  static const Color backgroundDark = Color(0xFF161332);

  /// Surface color for cards, sheets, and dialogs (dark mode)
  static const Color surfaceDark = Color(0xFF1D1942);

  /// Elevated surface for dialogs, modals, and bottom sheets (dark mode)
  static const Color surfaceElevatedDark = Color(0xFF251F52);

  /// Outline color for borders and dividers (dark mode)
  static const Color outlineDark = Color(0xFF2D265A);

  /// Subtle container for selected states, chips, and secondary backgrounds (dark mode)
  static const Color subtleContainerDark = Color(0xFF3A2F6D);

  /// Primary text color (dark mode)
  static const Color textPrimaryDark = Color(0xFFF6F4FC);

  /// Secondary text color (dark mode)
  static const Color textSecondaryDark = Color(0xFFB8B5D1);

  /// Gradient colors
  /// Gradient for balance card display
  /// Softer purple gradient
  static const LinearGradient balanceGradient = LinearGradient(
    colors: [Color(0xFF7C6AEF), Color(0xFFA199F7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
