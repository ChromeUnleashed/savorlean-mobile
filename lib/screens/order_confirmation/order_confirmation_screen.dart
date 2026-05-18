import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/placed_order.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/common/app_button.dart';

class OrderConfirmationScreen extends StatelessWidget {
  const OrderConfirmationScreen({super.key, required this.order});

  final PlacedOrder order;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: AppColors.oliveSoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  size: 44,
                  color: AppColors.olive,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Order Placed!',
                style: AppTextStyles.headingSerif.copyWith(fontSize: 30),
              ),
              const SizedBox(height: 12),
              Text(
                "We've received your order and will confirm it shortly.",
                style: AppTextStyles.bodyMuted,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.cream,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Column(
                  children: [
                    _DetailRow(
                      label: 'Order ID',
                      value: order.id.substring(0, 8).toUpperCase(),
                    ),
                    const SizedBox(height: 12),
                    _DetailRow(
                      label: 'Items',
                      value:
                          '${order.itemCount} item${order.itemCount > 1 ? 's' : ''}',
                    ),
                    const SizedBox(height: 12),
                    _DetailRow(
                      label: 'Total',
                      value: 'Rs. ${order.totalPkr}',
                      bold: true,
                    ),
                    const SizedBox(height: 12),
                    _DetailRow(
                      label: 'Payment',
                      value: order.paymentMethod == 'cod'
                          ? 'Cash on Delivery'
                          : 'Bank Transfer',
                    ),
                  ],
                ),
              ),
              const Spacer(),
              AppButton(
                label: 'Continue Shopping',
                onPressed: () => context.go('/'),
                variant: AppButtonVariant.primary,
                fullWidth: true,
              ),
              const SizedBox(height: 12),
              AppButton(
                label: 'View Order History',
                onPressed: () => context.go('/account/orders'),
                variant: AppButtonVariant.secondary,
                fullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMuted),
        Text(
          value,
          style: AppTextStyles.inter(
            fontSize: bold ? 16 : 14,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
