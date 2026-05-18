// lib/providers/auth_provider.dart
// Riverpod providers for Supabase authentication state.
// These providers are used by screens to react to sign-in / sign-out events.
// The router's _AuthChangeNotifier handles navigation redirects separately.

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_provider.g.dart';

/// Provides a live stream of Supabase auth state changes.
/// Widgets that watch this will rebuild on every sign-in, sign-out,
/// or token refresh event.
@riverpod
Stream<AuthState> authStateChanges(Ref ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
}

/// Provides the currently signed-in Supabase User, or null if not signed in.
/// Re-evaluates automatically whenever the auth state changes.
@riverpod
User? currentUser(Ref ref) {
  // Watching authStateChanges ensures this re-runs on every auth event.
  ref.watch(authStateChangesProvider);
  return Supabase.instance.client.auth.currentUser;
}
