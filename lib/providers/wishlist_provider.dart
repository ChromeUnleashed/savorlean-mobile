// lib/providers/wishlist_provider.dart
// Riverpod provider for the user's wishlist — a set of meal IDs they have saved.
// Uses AsyncNotifier so we can both fetch data AND mutate it (toggle).
// Supports optimistic updates — the heart flips instantly while the DB syncs.

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../providers/auth_provider.dart';
import '../services/wishlist_service.dart';

part 'wishlist_provider.g.dart';

/// Holds the set of meal IDs the signed-in user has wishlisted.
/// Returns an empty set when no user is signed in.
/// Watching currentUserProvider means this automatically re-runs on sign-in/out.
@riverpod
class Wishlist extends _$Wishlist {
  @override
  Future<Set<String>> build() async {
    // Re-run whenever auth state changes (sign-in or sign-out).
    final user = ref.watch(currentUserProvider);
    if (user == null) return {};

    return WishlistService().fetchWishlistIds(user.id);
  }

  /// Toggles a meal's wishlist status.
  /// Applies an optimistic update immediately so the heart responds instantly,
  /// then syncs with the database. Reverts the UI if the DB call fails.
  Future<void> toggle(String mealId) async {
    // We need the user to be signed in to wishlist anything.
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    // Read the current set of IDs (default to empty if still loading).
    final current = state.asData?.value ?? {};
    final alreadyLiked = current.contains(mealId);

    // Build the new set — add or remove the meal ID.
    final updated = Set<String>.from(current);
    if (alreadyLiked) {
      updated.remove(mealId);
    } else {
      updated.add(mealId);
    }

    // Optimistic update — flip the heart immediately in the UI.
    state = AsyncData(updated);

    try {
      // Sync the change to the database in the background.
      final service = WishlistService();
      if (alreadyLiked) {
        await service.removeFromWishlist(userId: user.id, mealId: mealId);
      } else {
        await service.addToWishlist(userId: user.id, mealId: mealId);
      }
    } catch (e) {
      // DB call failed — revert the optimistic update so the UI stays accurate,
      // then rethrow so the button can show the actual error to the user.
      state = AsyncData(current);
      rethrow;
    }
  }
}
