import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/data/models/category_model.dart' as models;
import 'package:expense_tracker/data/models/transaction_model.dart';
import 'package:expense_tracker/data/models/transaction_type.dart';
import 'package:expense_tracker/presentation/feedback/app_toast.dart';
import 'package:expense_tracker/presentation/providers/category_provider.dart';
import 'package:expense_tracker/presentation/providers/transaction_provider.dart';
import 'package:expense_tracker/presentation/widgets/category_selector.dart';
import 'package:expense_tracker/presentation/widgets/custom_button.dart';
import 'package:expense_tracker/presentation/widgets/transaction_amount_field.dart';
import 'package:expense_tracker/presentation/widgets/transaction_type_toggle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Modal bottom sheet for adding or editing transactions.
///
/// Displays form with amount, type, category, note, and date fields.
/// Validates input before submission and handles loading states.
class TransactionFormScreen extends ConsumerStatefulWidget {
  /// Existing transaction to edit (null for add mode).
  final TransactionModel? transaction;

  const TransactionFormScreen({
    super.key,
    this.transaction,
  });

  @override
  ConsumerState<TransactionFormScreen> createState() =>
      _TransactionFormScreenState();
}

class _TransactionFormScreenState extends ConsumerState<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _amountFocus = FocusNode();
  final _noteFocus = FocusNode();

  /// Selected transaction type (default: expense).
  TransactionType _selectedType = TransactionType.expense;

  /// Selected category (null if none selected).
  models.CategoryModel? _selectedCategory;

  /// Selected transaction date (default: today).
  DateTime _selectedDate = DateTime.now();

  /// Loading state during save operation.
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    if (widget.transaction != null) {
      _selectedType = widget.transaction!.type;
      _amountController.text = widget.transaction!.amount.toString();
      _selectedCategory = ref
          .read(categoryProvider.notifier)
          .getById(widget.transaction!.categoryId);
      _selectedDate = widget.transaction!.transactionDate;
      _noteController.text = widget.transaction!.note ?? '';
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _amountFocus.dispose();
    _noteFocus.dispose();
    super.dispose();
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
    AppToast.success(context, 'Lưu thành công!');
  }

  String? _validateCategory(models.CategoryModel? value) {
    if (value == null) {
      return 'Vui lòng chọn danh mục';
    }
    return null;
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      _showError('Bạn cần đăng nhập để thực hiện thao tác này');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final transactionNotifier = ref.read(transactionProvider.notifier);

      if (widget.transaction == null) {
        await transactionNotifier.addTransaction(
          TransactionModel(
            id: '',
            userId: userId,
            categoryId: _selectedCategory!.id,
            amount: double.parse(_amountController.text),
            type: _selectedType,
            note: _noteController.text.isEmpty ? null : _noteController.text,
            transactionDate: _selectedDate,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
      } else {
        await transactionNotifier.updateTransaction(
          widget.transaction!.copyWith(
            categoryId: _selectedCategory!.id,
            amount: double.parse(_amountController.text),
            type: _selectedType,
            note: _noteController.text.isEmpty ? null : _noteController.text,
            transactionDate: _selectedDate,
          ),
        );
      }

      if (mounted) {
        _showSuccess();
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) Navigator.of(context).pop(true);
        });
      }
    } catch (e) {
      if (mounted) {
        _showError('Có lỗi xảy ra. Vui lòng thử lại.');
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final lastDate = DateTime(now.year, now.month + 1, 0);

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(now.year - 10),
      lastDate: lastDate,
    );

    if (picked != null && mounted) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoryProvider);
    final theme = Theme.of(context);

    final availableCategories = switch (_selectedType) {
      TransactionType.income => categoriesAsync.valueOrNull ?? [],
      TransactionType.expense => categoriesAsync.valueOrNull ?? [],
    };

    final filteredCategories =
        availableCategories.where((cat) => cat.type == _selectedType).toList();

    return PopScope(
      canPop: !_isLoading,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
            bottom: Radius.circular(0),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(24),
                  bottom: Radius.circular(0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.transaction == null
                            ? 'Thêm giao dịch'
                            : 'Chỉnh sửa giao dịch',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      IconButton(
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.of(context).pop(false),
                        constraints: const BoxConstraints(
                          minWidth: 48,
                          minHeight: 48,
                        ),
                        icon: Icon(
                          Icons.close_rounded,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TransactionAmountField(
                          amount: double.tryParse(_amountController.text) ?? 0,
                          onChanged: (value) =>
                              _amountController.text = value.toString(),
                          focusNode: _amountFocus,
                          enabled: !_isLoading,
                        ),
                        const SizedBox(height: 24),
                        TransactionTypeToggle(
                          selectedType: _selectedType,
                          onChanged: (type) {
                            if (mounted) {
                              setState(() {
                                _selectedType = type;
                                _selectedCategory = null;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 24),
                        CategorySelector(
                          categories: filteredCategories,
                          selectedCategory: _selectedCategory,
                          onChanged: (category) {
                            if (mounted) {
                              setState(() => _selectedCategory = category);
                            }
                          },
                          errorText: _validateCategory(_selectedCategory),
                          enabled: !_isLoading,
                        ),
                        const SizedBox(height: 24),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.outline,
                              width: 1,
                            ),
                          ),
                          child: InkWell(
                            onTap: _isLoading ? null : _selectDate,
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today_rounded,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Ngày: ${_formatDate(_selectedDate)}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.5),
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.outline,
                              width: 1,
                            ),
                          ),
                          child: TextField(
                            controller: _noteController,
                            focusNode: _noteFocus,
                            enabled: !_isLoading,
                            maxLines: 3,
                            style: TextStyle(
                              fontSize: 16,
                              color: theme.colorScheme.onSurface,
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(16),
                              hintText: 'Ghi chú (tùy chọn)',
                              hintStyle: TextStyle(
                                fontSize: 16,
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        CustomButton(
                          text: widget.transaction == null
                              ? 'Thêm giao dịch'
                              : 'Lưu thay đổi',
                          onPressed: _isLoading ? null : _handleSave,
                          isLoading: _isLoading,
                          fullWidth: true,
                          icon: Icons.save_rounded,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Formats date for Vietnamese display.
  ///
  /// Uses DD/MM/YYYY format commonly used in Vietnam.
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

/// Displays transaction form as modal bottom sheet.
///
/// Can be called from anywhere in app to add or edit transactions.
/// Returns true if transaction was saved, false if cancelled.
Future<bool?> showTransactionForm(
  BuildContext context, {
  TransactionModel? transaction,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.95,
        ),
        child: SingleChildScrollView(
          controller: scrollController,
          child: TransactionFormScreen(transaction: transaction),
        ),
      ),
    ),
  );
}
