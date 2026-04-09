import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/data/models/category_model.dart' as models;
import 'package:flutter/material.dart';

/// Dropdown selector for transaction categories.
///
/// Shows category icon, name, and color for visual identification.
/// Updates available options based on transaction type selection.
class CategorySelector extends StatelessWidget {
  /// List of all categories to choose from.
  final List<models.CategoryModel> categories;

  /// Currently selected category (null if none selected).
  final models.CategoryModel? selectedCategory;

  /// Callback when user selects a category.
  final ValueChanged<models.CategoryModel?> onChanged;

  /// Optional error message to display below selector.
  final String? errorText;

  /// Whether selector is disabled.
  final bool enabled;

  const CategorySelector({
    super.key,
    required this.categories,
    required this.onChanged,
    this.selectedCategory,
    this.errorText,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Show disabled state while categories are loading/empty
    final isEmpty = categories.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Danh mục',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: errorText != null
                  ? AppColors.error
                  : AppColors.outline,
              width: 1,
            ),
          ),
          child: DropdownButtonFormField<models.CategoryModel>(
            initialValue: selectedCategory,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              hintStyle: TextStyle(
                fontSize: 16,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              hintText: isEmpty
                  ? 'Không có danh mục nào'
                  : 'Chọn danh mục',
              suffixIcon: selectedCategory != null
                  ? null
                  : Icon(
                      Icons.close,
                      size: 20,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
            ),
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.primary,
            ),
            isExpanded: true,
            items: categories
                .map(
                  (category) => DropdownMenuItem<models.CategoryModel>(
                    value: category,
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Color(
                              int.parse(category.color.substring(1), radix: 16),
                            ).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _getIconData(category.icon),
                            color: Color(
                              int.parse(category.color.substring(1), radix: 16),
                            ),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            category.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
            onChanged: (enabled && !isEmpty) ? onChanged : null,
            validator: isEmpty
                ? null
                : (value) {
                    if (value == null) {
                      return 'Vui lòng chọn danh mục';
                    }
                    return null;
                  },
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Text(
              errorText!,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.error,
              ),
            ),
          )
        else
          const SizedBox(height: 8),
      ],
    );
  }

  /// Maps category icon string to IconData.
  ///
  /// Uses predefined Material Design icon mappings.
  /// Returns default category icon if name not found.
  IconData _getIconData(String iconName) {
    final iconMap = <String, IconData>{
      'payments': Icons.payments_rounded,
      'card_giftcard': Icons.card_giftcard_rounded,
      'trending_up': Icons.trending_up_rounded,
      'storefront': Icons.storefront_rounded,
      'attach_money': Icons.attach_money_rounded,
      'restaurant': Icons.restaurant_rounded,
      'directions_car': Icons.directions_car_rounded,
      'shopping_bag': Icons.shopping_bag_rounded,
      'sports_esports': Icons.sports_esports_rounded,
      'local_hospital': Icons.local_hospital_rounded,
      'school': Icons.school_rounded,
      'receipt_long': Icons.receipt_long_rounded,
      'home': Icons.home_rounded,
      'account_balance': Icons.account_balance_rounded,
      'more_horiz': Icons.more_horiz_rounded,
    };

    return iconMap[iconName] ?? Icons.category_rounded;
  }
}
