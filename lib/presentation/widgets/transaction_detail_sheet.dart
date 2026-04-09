import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/data/models/category_model.dart' as models;
import 'package:expense_tracker/data/models/transaction_model.dart';
import 'package:expense_tracker/data/models/transaction_type.dart';
import 'package:expense_tracker/presentation/feedback/app_dialog.dart';
import 'package:expense_tracker/presentation/feedback/app_toast.dart';
import 'package:expense_tracker/presentation/providers/transaction_provider.dart';
import 'package:expense_tracker/presentation/screens/transactions/transaction_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Transaction detail bottom sheet with premium UX.
class TransactionDetailSheet extends StatelessWidget {
  final TransactionModel transaction;
  final models.CategoryModel? category;

  const TransactionDetailSheet({
    super.key,
    required this.transaction,
    this.category,
  });

  @override
  Widget build(BuildContext context) {
    // This widget is only used via the static show() method.
    // The build method is not intended to be used directly.
    return const SizedBox.shrink();
  }

  static Future<bool?> show(
    BuildContext context, {
    required TransactionModel transaction,
    required models.CategoryModel? category,
  }) {
    final isExpense = transaction.type == TransactionType.expense;
    final amountColor = isExpense ? AppColors.textPrimary : AppColors.success;
    final amountPrefix = isExpense ? '-' : '+';

    final iconColor = category != null
        ? Color(int.parse(category.color.replaceAll('#', '0xFF')))
        : AppColors.textSecondary;

    final iconData = _getIconData(category?.icon);

    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(color: Colors.transparent),
          child: DraggableScrollableSheet(
            initialChildSize: 0.5,
            minChildSize: 0.4,
            maxChildSize: 0.6,
            expand: false,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildDragHandle(),
                      const SizedBox(height: 24),
                      _buildCategoryRow(category, iconColor, iconData),
                      const SizedBox(height: 20),
                      _buildAmountRow(amountPrefix, transaction.amount, amountColor),
                      const SizedBox(height: 20),
                      _buildDateRow(transaction.transactionDate),
                      if (transaction.note != null && transaction.note!.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        _buildNoteSection(transaction.note!),
                      ],
                      const SizedBox(height: 24),
                      _buildActions(
                        context,
                        transaction,
                        category,
                        iconColor,
                        iconData,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  static Widget _buildDragHandle() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 12),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.outline.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  static Widget _buildCategoryRow(
    models.CategoryModel? category,
    Color iconColor,
    IconData iconData,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(iconData, color: iconColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              category?.name ?? 'Không rõ danh mục',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildAmountRow(
    String amountPrefix,
    double amount,
    Color amountColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Text(
            amountPrefix,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              CurrencyFormatter.format(amount),
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: amountColor,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildDateRow(DateTime date) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          const Icon(
            Icons.calendar_today_rounded,
            color: AppColors.textSecondary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            _formatDate(date),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildNoteSection(String note) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          note,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: AppColors.textPrimary,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  static Widget _buildActions(
    BuildContext context,
    TransactionModel transaction,
    models.CategoryModel? category,
    Color iconColor,
    IconData iconData,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
                showTransactionForm(
                  context,
                  transaction: transaction,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Chỉnh sửa',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Consumer(
            builder: (context, ref, _) {
              return SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    AppDialog.confirmDestructive(
                      context,
                      title: 'Xóa giao dịch',
                      content: 'Bạn có chắc muốn xóa giao dịch này không?',
                    ).then((confirmed) {
                      if (confirmed == true) {
                        ref
                            .read(transactionProvider.notifier)
                            .deleteTransaction(transaction.id)
                            .then((_) {
                              if (context.mounted) {
                                Navigator.of(context).pop(true);
                                AppToast.success(context, 'Đã xóa giao dịch');
                              }
                            });
                      }
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(
                      color: AppColors.error,
                      width: 1.5,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Xóa',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  static IconData _getIconData(String? iconString) {
    if (iconString == null) return Icons.category;
    try {
      return IconData(int.parse(iconString), fontFamily: 'MaterialIcons');
    } catch (_) {
      return Icons.category;
    }
  }
}
