import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../models/meal.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../common/loading_indicator.dart';

class MealCard extends StatelessWidget {
  final Meal meal;
  final VoidCallback? onTap;
  final VoidCallback? onWishlistTap;
  final bool isWishlisted;

  const MealCard({
    super.key,
    required this.meal,
    this.onTap,
    this.onWishlistTap,
    this.isWishlisted = false,
  });

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
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Rs. ${meal.pricePkr}',
                          style: AppTextStyles.price,
                        ),
                      ),
                      GestureDetector(
                        onTap: onWishlistTap,
                        child: Icon(
                          isWishlisted ? Icons.favorite : Icons.favorite_border,
                          size: 20,
                          color: isWishlisted
                              ? AppColors.cta
                              : AppColors.textMuted,
                        ),
                      ),
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
