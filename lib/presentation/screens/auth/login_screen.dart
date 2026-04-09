import 'dart:io';

import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/utils/error_messages.dart';
import 'package:expense_tracker/presentation/feedback/app_toast.dart';
import 'package:expense_tracker/presentation/providers/auth_provider.dart';
import 'package:expense_tracker/presentation/widgets/custom_button.dart';
import 'package:expense_tracker/presentation/widgets/custom_text_field.dart';
import 'package:expense_tracker/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

/// Handles user authentication via Email/Password.
///
/// Manages local form state and orchestrates the authentication flow
/// interacting with [AuthProvider].
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  /// Prevents UI interaction while async auth operations are in progress.
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  /// Validates email format using standard regex.
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email không được để trống';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Email không hợp lệ';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mật khẩu không được để trống';
    }
    if (value.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }

    return null;
  }

  /// Shows error feedback using AppToast.
  ///
  /// Replaces SnackBar for modern, non-blocking notification.
  void _showError(String message) {
    if (!mounted) return;
    AppToast.error(context, message);
  }

  /// Shows success feedback using AppToast.
  ///
  /// Replaces SnackBar for modern, non-blocking notification.
  void _showSuccess() {
    if (!mounted) return;
    AppToast.success(context, 'Đăng nhập thành công!');
  }

  /// Executes the login flow.
  ///
  /// Includes form validation, loading state management, and error handling
  /// for Supabase, Socket, and generic exceptions.
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authNotifier = ref.read(authProvider.notifier);

      await authNotifier.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final authState = ref.read(authProvider);

      // AuthGate will handle navigation - we only show feedback here
      if (authState.error != null) {
        _showError(authState.error!);
      } else if (authState.isAuthenticated) {
        if (mounted) {
          _showSuccess();
        }
      }
    } on supabase.AuthException catch (e) {
      _showError(ErrorMessages.parseSupabaseError(e.message));
    } on SocketException {
      _showError('Lỗi kết nối mạng. Vui lòng kiểm tra internet và thử lại');
    } catch (e) {
      _showError(ErrorMessages.parseException(e));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: !_isLoading,
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.background,
              elevation: 0,
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 48),
                    const Icon(
                      Icons.account_balance_wallet,
                      size: 80,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 48),
                    Text(
                      'Chào mừng quay trở lại',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          CustomTextField(
                            labelText: 'Email',
                            hintText: 'Nhập email của bạn',
                            controller: _emailController,
                            focusNode: _emailFocus,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            validator: _validateEmail,
                            onFieldSubmitted: (_) => FocusScope.of(context)
                                .requestFocus(_passwordFocus),
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            labelText: 'Mật khẩu',
                            hintText: 'Nhập mật khẩu',
                            controller: _passwordController,
                            focusNode: _passwordFocus,
                            obscureText: true,
                            textInputAction: TextInputAction.done,
                            validator: _validatePassword,
                            onFieldSubmitted: (_) {
                              FocusScope.of(context).unfocus();
                              _handleLogin();
                            },
                          ),
                          const SizedBox(height: 24),
                          CustomButton(
                            text: 'Đăng nhập',
                            onPressed: _isLoading ? null : _handleLogin,
                            isLoading: _isLoading,
                            fullWidth: true,
                            icon: Icons.login,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.of(context)
                              .pushNamed(AppRoutes.register),
                      child: Text.rich(
                        TextSpan(
                          text: 'Chưa có tài khoản? ',
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.7),
                          ),
                          children: const [
                            TextSpan(
                              text: 'Đăng ký',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Loading Overlay - Positioned to cover's entire screen context.
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.surface),
                    strokeWidth: 3,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
