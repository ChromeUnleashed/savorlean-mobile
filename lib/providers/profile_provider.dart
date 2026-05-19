// lib/providers/profile_provider.dart
// Riverpod provider for the signed-in user's profile data.
// Connects ProfileService to the UI layer — screens watch this provider
// instead of calling the service or Supabase directly.

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/user_profile.dart';
import '../providers/auth_provider.dart';
import '../services/profile_service.dart';

part 'profile_provider.g.dart';

/// Provides the currently signed-in user's profile from the database.
/// Returns null if the user is not signed in, or if no profile row exists yet.
/// Automatically re-fetches when the user signs in or out (watches currentUserProvider).
@riverpod
Future<UserProfile?> userProfile(Ref ref) async {
  // Watch the current user — if auth state changes, this provider re-runs automatically.
  final user = ref.watch(currentUserProvider);

  // User is not signed in — no profile to fetch.
  if (user == null) return null;

  // Fetch the profile from the database via the service.
  final service = ProfileService();
  return service.fetchProfile(user.id);
}
