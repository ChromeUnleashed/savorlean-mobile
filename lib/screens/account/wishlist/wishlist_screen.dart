// lib/screens/account/wishlist/wishlist_screen.dart
// Shows all meals the signed-in user has saved to their wishlist.
// Fetches the wishlist ID set and the full meal list, then shows only the
// meals whose IDs appear in the wishlist. Tapping the heart removes a meal.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../providers/meal_provider.dart';
import '../../../providers/wishlist_provider.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../widgets/common/loading_indicator.dart';
import '../../../widgets/meal_card/meal_card.dart';

/// Wishlist screen — a grid of meals the user has hearted.
class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch both providers — we need the ID set AND full meal objects.
    final wishlistAsync = ref.watch(wishlistProvider);
    final mealsAsync = ref.watch(mealsProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        title: const Text('My Wishlist'),
      ),
      body: _buildBody(context, ref, wishlistAsync, mealsAsync),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<Set<String>> wishlistAsync,
    AsyncValue mealsAsync,
  ) {
    if (wishlistAsync.isLoading || mealsAsync.isLoading) {
      return GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.72,
        ),
        itemCount: 4,
        itemBuilder: (_, _) => const AppMealCardSkeleton(),
      );
    }

    // Error state — show a message with a retry button.
    if (wishlistAsync.hasError || mealsAsync.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Could not load wishlist.', style: AppTextStyles.bodyMuted),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                ref.invalidate(wishlistProvider);
                ref.invalidate(mealsProvider);
              },
              child: const Text('Try again'),
            ),
          ],
        ),
      );
    }

    // Both loaded — filter the full meal list to those in the wishlist.
    final wishlistIds = wishlistAsync.asData!.value;
    final allMeals = (mealsAsync.asData!.value as List);
    final wishlisted = allMeals
        .where((m) => wishlistIds.contains(m.id))
        .toList();

    // Empty state — user has no saved meals yet.
    if (wishlisted.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.favorite_outline,
              size: 64,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 16),
            Text('No saved meals yet', style: AppTextStyles.headingBold),
            const SizedBox(height: 8),
            Text(
              'Tap the heart on any meal to save it here.',
              style: AppTextStyles.bodyMuted,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => context.go('/menu'),
              child: Text(
                'Browse Menu',
                style: AppTextStyles.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.cta,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Grid of wishlisted meal cards.
    // Tapping the heart on any card removes it from the wishlist via WishlistButton.
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      itemCount: wishlisted.length,
      itemBuilder: (context, i) {
        final meal = wishlisted[i];
        return MealCard(
          meal: meal,
          onTap: () => context.push('/menu/${meal.slug}'),
        );
      },
    );
  }
}
