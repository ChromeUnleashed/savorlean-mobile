// lib/widgets/meal_card/meal_card.dart
// A card widget that displays a single meal in a grid.
// Shows the meal image, category label, name, price, and a wishlist heart.
// Used on the Menu screen, Home screen (featured meals), and Wishlist screen.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../models/meal.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../common/loading_indicator.dart';
import '../wishlist_button/wishlist_button.dart';

/// Card displaying a single meal with image, name, price, and wishlist toggle.
class MealCard extends StatelessWidget {
  const MealCard({super.key, required this.meal, this.onTap});

  final Meal meal;

  /// Called when the user taps anywhere on the card (except the heart).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(2),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Meal image ────────────────────────────────────────────────
            AspectRatio(
              aspectRatio: 4 / 3,
              child: meal.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: meal.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => const AppSkeletonBox(),
                      errorWidget: (_, _, _) =>
                          Container(color: AppColors.surface),
                    )
                  : Container(color: AppColors.surface),
            ),

            // ── Text content ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category label — shown in small olive caps above the name.
                  if (meal.categoryName != null)
                    Text(
                      meal.categoryName!.toUpperCase(),
                      style: AppTextStyles.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.olive,
                      ),
                    ),
                  const SizedBox(height: 4),

                  // Meal name — truncated to 2 lines if long.
                  Text(
                    meal.name,
                    style: AppTextStyles.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Price + wishlist heart on the same row.
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Rs. ${meal.pricePkr}',
                          style: AppTextStyles.price,
                        ),
                      ),
                      // Self-contained wishlist button — handles auth and DB sync.
                      WishlistButton(mealId: meal.id),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
