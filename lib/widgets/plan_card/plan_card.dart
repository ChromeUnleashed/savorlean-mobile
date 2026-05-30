// lib/widgets/plan_card/plan_card.dart
// Card widget for displaying a subscription plan in a list.
// Shows the plan image (or a branded fallback), type badge, name,
// description, and starting price. Used on the Plans tab and Home screen.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../models/subscription_plan.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class PlanCard extends StatelessWidget {
  final SubscriptionPlan plan;
  final VoidCallback? onTap;

  const PlanCard({super.key, required this.plan, this.onTap});

  @override
  Widget build(BuildContext context) {
    final startingPrice = plan.startingPrice;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image section ──────────────────────────────────────────
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Plan image, or an olive-tinted fallback if none uploaded yet.
                  _PlanImage(imageUrl: plan.imageUrl),

                  // Type badge overlaid on the bottom-left of the image.
                  Positioned(
                    left: 12,
                    bottom: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.olive,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Text(
                        plan.type.toUpperCase(),
                        style: AppTextStyles.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Text section ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Plan name + arrow on the same row.
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          plan.name,
                          style: AppTextStyles.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: AppColors.textMuted,
                      ),
                    ],
                  ),
                  if (plan.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      plan.description,
                      style: AppTextStyles.bodyMuted,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (startingPrice != null) ...[
                    const SizedBox(height: 10),
                    Text('From Rs. $startingPrice', style: AppTextStyles.price),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Renders the plan image if a URL is available, otherwise shows a branded
/// olive placeholder with a restaurant icon.
class _PlanImage extends StatelessWidget {
  final String? imageUrl;
  const _PlanImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return Container(
        color: AppColors.oliveSoft,
        child: const Icon(
          Icons.restaurant_menu,
          size: 48,
          color: AppColors.olive,
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl!,
      fit: BoxFit.cover,
      placeholder: (_, _) => Container(color: AppColors.surface),
      errorWidget: (_, _, _) => Container(
        color: AppColors.oliveSoft,
        child: const Icon(
          Icons.restaurant_menu,
          size: 48,
          color: AppColors.olive,
        ),
      ),
    );
  }
}
