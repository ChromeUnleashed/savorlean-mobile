// lib/widgets/plan_card/custom_plan_banner.dart
// Hero banner for the single custom/build-your-own plan.
// Rendered above the ready-made plan cards with a distinct cream background
// and a CTA button so users immediately know this is a different kind of option.
// Also exports PlanSectionLabel — the divider used to split the two sections.

import 'package:flutter/material.dart';

import '../../models/subscription_plan.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// Full-width hero banner for the custom plan.
/// Uses a cream background (no image) to visually separate it from the
/// image-on-top PlanCard widgets used for ready-made plans.
class CustomPlanBanner extends StatelessWidget {
  final SubscriptionPlan plan;
  final VoidCallback? onTap;

  const CustomPlanBanner({super.key, required this.plan, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cream,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppColors.border),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Small uppercase eyebrow label — signals this is a customisable option.
            Text('BUILD YOUR OWN', style: AppTextStyles.sectionTitle),
            const SizedBox(height: 8),

            // Plan name in bold — the headline of the banner.
            Text(
              plan.name,
              style: AppTextStyles.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),

            if (plan.description.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                plan.description,
                style: AppTextStyles.bodyMuted,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            const SizedBox(height: 16),

            // Bottom row: starting price on the left, CTA button on the right.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (plan.startingPrice != null)
                  Text(
                    'From Rs. ${plan.startingPrice}',
                    style: AppTextStyles.price,
                  ),
                // CTA button styled to match the Add to Cart button.
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.cta,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Start Building',
                        style: AppTextStyles.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.arrow_forward,
                        size: 14,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Horizontal section divider with a centred label.
/// Used between the custom plan banner and the ready-made plan cards.
class PlanSectionLabel extends StatelessWidget {
  final String label;

  const PlanSectionLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(label, style: AppTextStyles.sectionTitle),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}
