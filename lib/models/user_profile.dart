// lib/models/user_profile.dart
// Represents a user's editable profile stored in the Supabase 'profiles' table.
// This is separate from Supabase Auth metadata — it holds display name and phone number
// that the user can update after registration.

/// A user's editable profile information from the 'profiles' database table.
class UserProfile {
  const UserProfile({required this.id, this.fullName, this.phoneNumber});

  /// The user's unique ID — matches their Supabase auth user ID.
  final String id;

  /// The user's display name as stored in the profiles table.
  /// May be null if the user has never saved a name.
  final String? fullName;

  /// The user's phone number (Pakistani format: +92 XXX XXXXXXX).
  /// May be null if the user has never saved a phone number.
  final String? phoneNumber;

  /// Creates a UserProfile from a Supabase row map returned by a .select() call.
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as String,
      fullName: map['full_name'] as String?,
      phoneNumber: map['phone_number'] as String?,
    );
  }
}
