// lib/services/profile_service.dart
// Handles reading and writing user profile data to the Supabase 'profiles' table.
// The profiles table stores extra information about the user (name, phone number)
// beyond what Supabase Auth stores automatically.
// This service is the only place in the app that talks to the 'profiles' table.

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_profile.dart';

/// Service class for all profile-related Supabase operations.
class ProfileService {
  // Supabase client — initialised once in main.dart and accessed here as a singleton.
  final _client = Supabase.instance.client;

  /// Fetches the profile row for a given user ID.
  /// Returns null if the profile row does not exist yet (new user before first checkout).
  /// Returns null on network/database error so the UI degrades gracefully.
  Future<UserProfile?> fetchProfile(String userId) async {
    try {
      // Query the profiles table for this user's row.
      // maybeSingle() returns null instead of throwing if no row is found.
      final data = await _client
          .from('profiles')
          .select('id, full_name, phone_number')
          .eq('id', userId)
          .maybeSingle();

      // No profile row exists yet — return null.
      if (data == null) return null;

      return UserProfile.fromMap(data);
    } catch (_) {
      // Network error or RLS rejection — return null so the UI falls back gracefully.
      return null;
    }
  }

  /// Creates or updates (upserts) the profile row for the given user.
  /// Only updates fields that are explicitly passed — null parameters are skipped.
  /// Throws on database error so callers can show an error message.
  Future<void> upsertProfile({
    required String userId,
    String? fullName,
    String? phoneNumber,
  }) async {
    // Build the update map — only include fields that were provided.
    final payload = <String, dynamic>{'id': userId};
    if (fullName != null) payload['full_name'] = fullName;
    if (phoneNumber != null) payload['phone_number'] = phoneNumber;

    await _client.from('profiles').upsert(payload);
  }
}
