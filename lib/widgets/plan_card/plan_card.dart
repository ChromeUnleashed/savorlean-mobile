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
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(2),
          border: Border(left: BorderSide(color: AppColors.olive, width: 4)),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.oliveSoft,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Text(
                      plan.type.toUpperCase(),
                      style: AppTextStyles.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.olive,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Plan name
                  Text(
                    plan.name,
                    style: AppTextStyles.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
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
                    const SizedBox(height: 8),
                    Text('From Rs. $startingPrice', style: AppTextStyles.price),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
