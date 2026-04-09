import 'transaction_type.dart';

/// Immutable data model representing a financial transaction.
/// Uses JSON serialization for Supabase integration.
/// Ensures type safety through null-safe fields and enum constraints.
class TransactionModel {
  /// Unique identifier from Supabase UUID generation.
  final String id;

  /// Foreign key reference to owning user's profile.
  final String userId;

  /// Foreign key reference to associated category.
  final String categoryId;

  /// Transaction amount in Vietnamese Dong (VND).
  /// Stored as NUMERIC(15,2) in database for precise financial calculations.
  final double amount;

  /// Type classification affecting balance calculations.
  final TransactionType type;

  /// Optional user-provided description or note.
  /// Nullable in database, defaults to null when not provided.
  final String? note;

  /// When transaction actually occurred.
  /// Defaults to current timestamp in database if not specified.
  final DateTime transactionDate;

  /// Automatic timestamp from Supabase on record creation.
  /// Used for sorting and audit trails.
  final DateTime createdAt;

  /// Automatic timestamp from Supabase trigger on updates.
  /// Null for new records, set by database triggers on modification.
  final DateTime updatedAt;

  /// Const constructor for compile-time optimization.
  /// All fields are final ensuring immutability.
  const TransactionModel({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.amount,
    required this.type,
    this.note,
    required this.transactionDate,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Factory constructor to deserialize from Supabase JSON response.
  /// Handles snake_case to camelCase field mapping for database compatibility.
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      categoryId: json['category_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: TransactionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TransactionType.expense,
      ),
      note: json['note'] as String?,
      transactionDate: DateTime.parse(json['transaction_date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Converts model to JSON format for Supabase API requests.
  /// Transforms camelCase back to snake_case for database column matching.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'category_id': categoryId,
      'amount': amount,
      'type': type.name,
      'note': note,
      'transaction_date': transactionDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Creates a copy with optional field replacements.
  /// Enables immutable updates without modifying original instance.
  /// Used in edit scenarios and state management.
  TransactionModel copyWith({
    String? id,
    String? userId,
    String? categoryId,
    double? amount,
    TransactionType? type,
    String? note,
    DateTime? transactionDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      note: note ?? this.note,
      transactionDate: transactionDate ?? this.transactionDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Equality operator compares all fields for structural equality.
  /// Required for proper list operations and state comparison.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransactionModel &&
        other.id == id &&
        other.userId == userId &&
        other.categoryId == categoryId &&
        other.amount == amount &&
        other.type == type &&
        other.note == note &&
        other.transactionDate == transactionDate &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  /// Hash code derived from all fields for consistent hashing.
  /// Must override when overriding equality operator.
  @override
  int get hashCode {
    return Object.hash(
      id,
      userId,
      categoryId,
      amount,
      type,
      note,
      transactionDate,
      createdAt,
      updatedAt,
    );
  }
}
