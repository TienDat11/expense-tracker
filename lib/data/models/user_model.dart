// Packages
import 'package:supabase_flutter/supabase_flutter.dart';

/// User model representing application user
///
/// Maps to Supabase auth User with additional profile data
/// from the public profiles table.
class UserModel {
  /// Unique user identifier from Supabase auth
  final String id;

  /// User's email address (used for login)
  final String email;

  /// User's display name from profiles table
  final String? fullName;

  /// URL to user's avatar image
  final String? avatarUrl;

  /// Email verification status
  ///
  /// True if user has confirmed their email address.
  /// False for newly registered users pending verification.
  final bool emailConfirmedAt;

  /// User account creation timestamp
  final DateTime createdAt;

  /// User account last update timestamp
  final DateTime? updatedAt;

  /// Creates UserModel from Supabase auth User
  ///
  /// Extracts relevant fields from Supabase's User object.
  /// Maps user_metadata to profile fields (full_name, avatar_url).
  factory UserModel.fromSupabaseUser(User user) {
    // Extract profile data from user_metadata if available
    final metadata = user.userMetadata ?? {};

    return UserModel(
      id: user.id,
      email: user.email ?? '',
      fullName: metadata['full_name'] as String?,
      avatarUrl: metadata['avatar_url'] as String?,
      emailConfirmedAt: user.emailConfirmedAt != null,
      createdAt: DateTime.now(),
      updatedAt: null,
    );
  }

  /// Creates UserModel from profiles table data
  ///
  /// Used when fetching profile data directly from database.
  /// Combines auth user data with profile data.
  factory UserModel.fromProfileData({
    required String id,
    required String email,
    required Map<String, dynamic> profileData,
  }) {
    return UserModel(
      id: id,
      email: email,
      fullName: profileData['full_name'] as String?,
      avatarUrl: profileData['avatar_url'] as String?,
      emailConfirmedAt: true,
      createdAt: DateTime.parse(profileData['created_at']),
      updatedAt: profileData['updated_at'] != null
          ? DateTime.parse(profileData['updated_at'])
          : null,
    );
  }

  /// Constructor for creating UserModel with explicit values
  const UserModel({
    required this.id,
    required this.email,
    this.fullName,
    this.avatarUrl,
    required this.emailConfirmedAt,
    required this.createdAt,
    this.updatedAt,
  });

  /// Creates a copy of this UserModel with optionally modified fields
  ///
  /// Useful for state updates when user modifies their profile.
  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? avatarUrl,
    bool? emailConfirmedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      emailConfirmedAt: emailConfirmedAt ?? this.emailConfirmedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Checks if two UserModels are equal
  ///
  /// Compares all fields for strict equality.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel &&
        other.id == id &&
        other.email == email &&
        other.fullName == fullName &&
        other.avatarUrl == avatarUrl &&
        other.emailConfirmedAt == emailConfirmedAt &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  /// Generates hash code for UserModel
  ///
  /// Required for proper equality comparison.
  @override
  int get hashCode => Object.hash(
        id,
        email,
        fullName,
        avatarUrl,
        emailConfirmedAt,
        createdAt,
        updatedAt,
      );

  /// Converts UserModel to JSON for storage/transmission
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'email_confirmed_at': emailConfirmedAt,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Creates UserModel from JSON data
  ///
  /// Parses ISO8601 datetime strings and handles null values.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      emailConfirmedAt: json['email_confirmed_at'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }
}
