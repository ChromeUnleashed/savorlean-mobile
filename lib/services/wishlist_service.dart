// lib/services/wishlist_service.dart
// Handles reading and writing to the Supabase 'wishlists' table.
// The wishlist table stores which meals a user has saved (liked) with a heart.
// Each row links a user_id to a meal_id.

import 'package:supabase_flutter/supabase_flutter.dart';

/// Service class for all wishlist-related Supabase operations.
class WishlistService {
  final _client = Supabase.instance.client;

  /// Returns the set of meal IDs the given user has wishlisted.
  /// Returns an empty set if the user has no wishlist entries or on error.
  Future<Set<String>> fetchWishlistIds(String userId) async {
    try {
      // Select only the meal_id column for this user — we just need the IDs,
      // not the full meal data (that comes from the meals provider separately).
      final rows = await _client
          .from('wishlists')
          .select('meal_id')
          .eq('user_id', userId);

      // Build a Set<String> from the list of rows for O(1) lookup in the UI.
      return {
        for (final row in rows as List<dynamic>) row['meal_id'] as String,
      };
    } catch (_) {
      // On network error or RLS rejection, return an empty set so the UI
      // falls back gracefully (hearts show as un-filled).
      return {};
    }
  }

  /// Adds a meal to the user's wishlist.
  /// Throws on database error so the caller can revert the optimistic update.
  Future<void> addToWishlist({
    required String userId,
    required String mealId,
  }) async {
    await _client.from('wishlists').insert({
      'user_id': userId,
      'meal_id': mealId,
    });
  }

  /// Removes a meal from the user's wishlist.
  /// Throws on database error so the caller can revert the optimistic update.
  Future<void> removeFromWishlist({
    required String userId,
    required String mealId,
  }) async {
    await _client
        .from('wishlists')
        .delete()
        .eq('user_id', userId)
        .eq('meal_id', mealId);
  }
}
