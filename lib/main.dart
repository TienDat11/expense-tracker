import 'dart:async';

import 'package:expense_tracker/core/config/env.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
// Project
import 'package:expense_tracker/data/services/supabase_service.dart';
// Flutter
import 'package:expense_tracker/presentation/widgets/auth_gate.dart';
import 'package:expense_tracker/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// Packages
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Entry point for expense tracker application
///
/// Initializes Supabase service, wraps app in ProviderScope,
/// and sets up initial routing based on auth state.
Future<void> main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  debugPrint('[AUTH_DEBUG] ========================================');
  debugPrint('[AUTH_DEBUG] App Starting - Initialization Begin');
  debugPrint('[AUTH_DEBUG] ========================================');

  try {
    // Step 1: Initialize environment variables
    debugPrint('[AUTH_DEBUG] Step 1: Loading .env file...');
    await Env.initialize();
    debugPrint('[AUTH_DEBUG] Step 1: ✅ .env loaded successfully');

    // Step 2: Verify environment variables (security: only log lengths)
    debugPrint('[AUTH_DEBUG] Step 2: Verifying environment variables...');
    final supabaseUrl = Env.supabaseUrl;
    final supabaseAnonKey = Env.supabaseAnonKey;

    debugPrint('[AUTH_DEBUG]   - SUPABASE_URL length: ${supabaseUrl.length}');
    debugPrint(
        '[AUTH_DEBUG]   - SUPABASE_URL starts with https: ${supabaseUrl.startsWith('https://')}');
    debugPrint(
        '[AUTH_DEBUG]   - SUPABASE_ANON_KEY length: ${supabaseAnonKey.length}');
    debugPrint(
        '[AUTH_DEBUG]   - SUPABASE_ANON_KEY is not empty: ${supabaseAnonKey.isNotEmpty}');

    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      debugPrint('[AUTH_DEBUG] ❌ ERROR: Environment variables are empty!');
      throw Exception('Supabase credentials are empty');
    }

    debugPrint('[AUTH_DEBUG] Step 2: ✅ Environment variables verified');

    // Step 3: Initialize Supabase service
    debugPrint('[AUTH_DEBUG] Step 3: Initializing Supabase...');
    await SupabaseService.initialize();
    debugPrint('[AUTH_DEBUG] Step 3: ✅ Supabase initialized');

    // Step 4: Check current auth state
    debugPrint('[AUTH_DEBUG] Step 4: Checking current auth state...');
    final currentUser = SupabaseService.instance.currentUser;
    if (currentUser != null) {
      debugPrint('[AUTH_DEBUG]   - User ID: ${currentUser.id}');
      debugPrint('[AUTH_DEBUG]   - User Email: ${currentUser.email}');
      debugPrint(
          '[AUTH_DEBUG]   - Email Confirmed: ${currentUser.emailConfirmedAt != null}');
      debugPrint('[AUTH_DEBUG]   - Created At: ${currentUser.createdAt}');
    } else {
      debugPrint('[AUTH_DEBUG]   - No user currently logged in');
    }

    final currentSession = SupabaseService.instance.currentSession;
    if (currentSession != null) {
      debugPrint('[AUTH_DEBUG]   - Session exists: true');
      debugPrint(
          '[AUTH_DEBUG]   - Access token length: ${currentSession.accessToken.length}');
      debugPrint(
          '[AUTH_DEBUG]   - Token expires at: ${DateTime.fromMillisecondsSinceEpoch(currentSession.expiresAt! * 1000)}');
    } else {
      debugPrint('[AUTH_DEBUG]   - No active session');
    }

    debugPrint('[AUTH_DEBUG] Step 4: ✅ Auth state checked');
    debugPrint('[AUTH_DEBUG] ========================================');
    debugPrint('[AUTH_DEBUG] ✅ All initialization complete!');
    debugPrint('[AUTH_DEBUG] ========================================');
  } catch (e, stackTrace) {
    debugPrint('[AUTH_DEBUG] ❌ FATAL ERROR during initialization:');
    debugPrint('[AUTH_DEBUG] Error: $e');
    debugPrint('[AUTH_DEBUG] Stack trace: $stackTrace');
    // Still run: app, but with error state
  }

  // Run app with providers
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

/// Root widget of expense tracker application
///
/// Uses AuthGate as single source of truth for auth state and navigation.
/// Wraps MaterialApp with ProviderScope for dependency injection.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('[AUTH_DEBUG] MyApp.build() called - Rendering MaterialApp');

    return MaterialApp(
      title: 'Kimchi Expense Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: AppColors.primary,
          onPrimary: Colors.white,
          secondary: AppColors.accent,
          onSecondary: Colors.white,
          error: AppColors.error,
          onError: Colors.white,
          surface: AppColors.surface,
          onSurface: AppColors.textPrimary,
          outline: AppColors.outline,
          outlineVariant: AppColors.subtleContainer,
          surfaceContainer: AppColors.subtleContainer,
          surfaceContainerHigh: AppColors.surfaceElevated,
        ),
        scaffoldBackgroundColor: AppColors.background,
        cardTheme: const CardThemeData(
          color: AppColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
        dialogTheme: const DialogThemeData(
          backgroundColor: AppColors.surfaceElevated,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: AppColors.surfaceElevated,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.outline,
          thickness: 1,
          space: 1,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.subtleContainer,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.outline),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.outline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        // Typography: Be Vietnam Pro for Vietnamese readability
        fontFamily: GoogleFonts.beVietnamPro().fontFamily,
        textTheme: TextTheme(
          // Display & Titles
          displayLarge: GoogleFonts.beVietnamPro(
            fontSize: 32,
            fontWeight: FontWeight.w600,
            height: 1.2,
          ),
          titleLarge: GoogleFonts.beVietnamPro(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            height: 1.3,
            color: AppColors.textPrimary,
          ),
          titleMedium: GoogleFonts.beVietnamPro(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            height: 1.3,
            color: AppColors.textPrimary,
          ),
          // Body Text (primary - Vietnamese diacritic optimized)
          bodyLarge: GoogleFonts.beVietnamPro(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            height: 1.5,
            color: AppColors.textPrimary,
          ),
          bodyMedium: GoogleFonts.beVietnamPro(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.5,
            color: AppColors.textPrimary,
          ),
          bodySmall: GoogleFonts.beVietnamPro(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            height: 1.4,
            color: AppColors.textSecondary,
          ),
          // Labels & Buttons
          labelLarge: GoogleFonts.beVietnamPro(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            height: 1.4,
            color: AppColors.textPrimary,
          ),
          labelMedium: GoogleFonts.beVietnamPro(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            height: 1.4,
          ),
          // Captions & Hints
          labelSmall: GoogleFonts.beVietnamPro(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            height: 1.4,
            color: AppColors.textSecondary,
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme(
          brightness: Brightness.dark,
          primary: AppColors.primary,
          onPrimary: Colors.white,
          secondary: AppColors.accent,
          onSecondary: Colors.white,
          error: AppColors.error,
          onError: Colors.white,
          surface: AppColors.surfaceDark,
          onSurface: AppColors.textPrimaryDark,
          outline: AppColors.outlineDark,
          outlineVariant: AppColors.subtleContainerDark,
          surfaceContainer: AppColors.subtleContainerDark,
          surfaceContainerHigh: AppColors.surfaceElevatedDark,
        ),
        scaffoldBackgroundColor: AppColors.backgroundDark,
        cardTheme: const CardThemeData(
          color: AppColors.surfaceDark,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
        dialogTheme: const DialogThemeData(
          backgroundColor: AppColors.surfaceElevatedDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: AppColors.surfaceElevatedDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.outlineDark,
          thickness: 1,
          space: 1,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.subtleContainerDark,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.outlineDark),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.outlineDark),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        // Typography: Be Vietnam Pro for Vietnamese readability (dark mode)
        fontFamily: GoogleFonts.beVietnamPro().fontFamily,
        textTheme: TextTheme(
          displayLarge: GoogleFonts.beVietnamPro(
            fontSize: 32,
            fontWeight: FontWeight.w600,
            height: 1.2,
          ),
          titleLarge: GoogleFonts.beVietnamPro(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            height: 1.3,
            color: AppColors.textPrimaryDark,
          ),
          titleMedium: GoogleFonts.beVietnamPro(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            height: 1.3,
            color: AppColors.textPrimaryDark,
          ),
          bodyLarge: GoogleFonts.beVietnamPro(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            height: 1.5,
            color: AppColors.textPrimaryDark,
          ),
          bodyMedium: GoogleFonts.beVietnamPro(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.5,
            color: AppColors.textPrimaryDark,
          ),
          bodySmall: GoogleFonts.beVietnamPro(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            height: 1.4,
            color: AppColors.textSecondaryDark,
          ),
          labelLarge: GoogleFonts.beVietnamPro(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            height: 1.4,
            color: AppColors.textPrimaryDark,
          ),
          labelMedium: GoogleFonts.beVietnamPro(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            height: 1.4,
          ),
          labelSmall: GoogleFonts.beVietnamPro(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            height: 1.4,
            color: AppColors.textSecondaryDark,
          ),
        ),
      ),
      themeMode: ThemeMode.system,
      // Register named routes for navigation (login <-> register)
      routes: AppRouter.routes,
      // Use AuthGate as home - it will handle all auth-based navigation
      home: const AuthGate(),
    );
  }
}
