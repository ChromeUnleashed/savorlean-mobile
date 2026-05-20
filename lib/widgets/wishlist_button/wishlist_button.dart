// lib/widgets/wishlist_button/wishlist_button.dart
// A self-contained heart button that reads and writes the wishlist provider.
// Drop this widget anywhere a meal is displayed — it manages its own state.
// If the user is not signed in, tapping it redirects to the login screen.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../theme/app_colors.dart';

/// A heart icon button that toggles a meal's wishlist status.
/// Shows a filled red heart when wishlisted, an outlined grey heart when not.
/// [mealId] — the UUID of the meal (meal.id, not slug).
/// [size] — icon size, defaults to 20.
class WishlistButton extends ConsumerWidget {
  const WishlistButton({super.key, required this.mealId, this.size = 20});

  final String mealId;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Select only this meal's status — rebuilds only when THIS meal is toggled,
    // not when any other meal in the wishlist changes.
    final isWishlisted = ref.watch(
      wishlistProvider.select((v) => v.asData?.value.contains(mealId) ?? false),
    );

    return GestureDetector(
      onTap: () => _handleTap(context, ref),
      behavior: HitTestBehavior.opaque,
      // Add a small padding so the tap target is easy to hit on small screens.
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(
          isWishlisted ? Icons.favorite : Icons.favorite_border,
          size: size,
          color: isWishlisted ? AppColors.cta : AppColors.textMuted,
        ),
      ),
    );
  }

  /// Handles a tap on the heart button.
  /// Redirects to login if the user is not signed in.
  /// Otherwise toggles the meal's wishlist status optimistically.
  Future<void> _handleTap(BuildContext context, WidgetRef ref) async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      context.push('/login');
      return;
    }
    try {
      HapticFeedback.lightImpact();
      await ref.read(wishlistProvider.notifier).toggle(mealId);
    } catch (e) {
      // Show the real Supabase error so we can diagnose table/RLS issues.
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Wishlist error: $e')));
      }
    }
  }
}
