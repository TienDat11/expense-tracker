import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// Empty state variant for transactions.
enum EmptyStateVariant {
  /// First-time user - no transactions ever
  firstTime,

  /// User has transactions but filters hide them
  filtered,
}

/// Reusable empty state widget for transactions.
///
/// Renders different UI variants based on empty state type.
/// Uses design tokens for consistent styling.
/// Supports optional CTA button with customizable action.
class TransactionEmptyState extends StatelessWidget {
  /// Which variant to display
  final EmptyStateVariant variant;

  /// Optional callback for primary CTA button (first-time only)
  final VoidCallback? onPrimaryAction;

  /// Optional callback for secondary action (clear filters)
  final VoidCallback? onSecondaryAction;

  /// Custom icon widget (overrides default variant icon)
  final Widget? customIcon;

  const TransactionEmptyState({
    super.key,
    required this.variant,
    this.onPrimaryAction,
    this.onSecondaryAction,
    this.customIcon,
  });

  /// Creates first-time user empty state
  const TransactionEmptyState.firstTime({
    super.key,
    this.onPrimaryAction,
  })  : variant = EmptyStateVariant.firstTime,
        customIcon = null,
        onSecondaryAction = null;

  /// Creates filtered empty state
  const TransactionEmptyState.filtered({
    super.key,
    this.onSecondaryAction,
  })  : variant = EmptyStateVariant.filtered,
        customIcon = null,
        onPrimaryAction = null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIcon(context),
            const SizedBox(height: 24),
            _buildTitle(context, theme),
            const SizedBox(height: 8),
            _buildSubtitle(context, theme),
            if (variant == EmptyStateVariant.firstTime && onPrimaryAction != null) ...[
              const SizedBox(height: 24),
              _buildPrimaryButton(context),
            ],
            if (variant == EmptyStateVariant.filtered && onSecondaryAction != null) ...[
              const SizedBox(height: 24),
              _buildSecondaryButton(context),
            ],
          ],
        ),
      ),
    );
  }

  /// Builds icon based on variant
  Widget _buildIcon(BuildContext context) {
    if (customIcon != null) {
      return customIcon!;
    }

    final iconData = switch (variant) {
      EmptyStateVariant.firstTime => Icons.receipt_long_rounded,
      EmptyStateVariant.filtered => Icons.filter_list_off_rounded,
    };

    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData,
        size: 64,
        color: AppColors.primary.withValues(alpha: 0.5),
      ),
    );
  }

  /// Builds title based on variant
  Widget _buildTitle(BuildContext context, ThemeData theme) {
    final title = switch (variant) {
      EmptyStateVariant.firstTime => 'Chưa có giao dịch nào',
      EmptyStateVariant.filtered => 'Không có giao dịch phù hợp',
    };

    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.onSurface,
      ),
      textAlign: TextAlign.center,
    );
  }

  /// Builds subtitle based on variant
  Widget _buildSubtitle(BuildContext context, ThemeData theme) {
    final subtitle = switch (variant) {
      EmptyStateVariant.firstTime =>
          'Bắt đầu ghi lại chi tiêu để quản lý tài chính tốt hơn',
      EmptyStateVariant.filtered =>
          'Thử thay đổi bộ lọc để xem thêm giao dịch',
    };

    return Text(
      subtitle,
      style: TextStyle(
        fontSize: 14,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        height: 1.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  /// Builds primary CTA button (first-time variant only)
  Widget _buildPrimaryButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPrimaryAction,
      icon: const Icon(Icons.add_rounded, size: 20),
      label: const Text('Thêm giao dịch đầu tiên'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
        shadowColor: Colors.transparent,
      ).copyWith(
        overlayColor: WidgetStateProperty.all(
          Colors.white.withValues(alpha: 0.1),
        ),
      ),
    );
  }

  /// Builds secondary action button (filtered variant only)
  Widget _buildSecondaryButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onSecondaryAction,
      icon: const Icon(Icons.filter_alt_off_rounded, size: 18),
      label: const Text('Xóa bộ lọc'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        minimumSize: const Size.fromHeight(44),
        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
