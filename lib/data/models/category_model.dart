import 'transaction_type.dart';

/// Immutable data model representing a transaction category.
/// Uses JSON serialization for Supabase integration.
/// Supports both system-defined and user-created categories.
class CategoryModel {
  /// Unique identifier from Supabase UUID generation.
  final String id;

  /// Display name of the category (e.g., "Ăn uống", "Lương").
  /// Combined with type for unique constraint in database.
  final String name;

  /// Classification determining whether category applies to income or expense.
  final TransactionType type;

  /// Material Design icon name for visual representation.
  /// Corresponds to IconData.fromAssetName or icon name mappings.
  final String icon;

  /// Hex color code for category visual identification.
  /// Used in charts, cards, and category badges.
  final String color;

  /// Indicates if category is predefined by system vs user-created.
  /// System categories cannot be deleted by users.
  final bool isSystem;

  /// Automatic timestamp from Supabase on record creation.
  final DateTime createdAt;

  /// Const constructor for compile-time optimization.
  /// All fields are final ensuring immutability.
  const CategoryModel({
    required this.id,
    required this.name,
    required this.type,
    required this.icon,
    required this.color,
    required this.isSystem,
    required this.createdAt,
  });

  /// Factory constructor to deserialize from Supabase JSON response.
  /// Handles snake_case to camelCase field mapping for database compatibility.
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: TransactionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TransactionType.expense,
      ),
      icon: json['icon'] as String,
      color: json['color'] as String,
      isSystem: json['is_system'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Converts model to JSON format for Supabase API requests.
  /// Transforms camelCase back to snake_case for database column matching.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'icon': icon,
      'color': color,
      'is_system': isSystem,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Creates a copy with optional field replacements.
  /// Enables immutable updates without modifying original instance.
  CategoryModel copyWith({
    String? id,
    String? name,
    TransactionType? type,
    String? icon,
    String? color,
    bool? isSystem,
    DateTime? createdAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isSystem: isSystem ?? this.isSystem,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Equality operator compares all fields for structural equality.
  /// Required for proper list operations and state comparison.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoryModel &&
        other.id == id &&
        other.name == name &&
        other.type == type &&
        other.icon == icon &&
        other.color == color &&
        other.isSystem == isSystem &&
        other.createdAt == createdAt;
  }

  /// Hash code derived from all fields for consistent hashing.
  /// Must override when overriding equality operator.
  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      type,
      icon,
      color,
      isSystem,
      createdAt,
    );
  }
}
