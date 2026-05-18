import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/cart_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/cart_item_tile/cart_item_tile.dart';
import '../../widgets/common/app_button.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(cartProvider);
    final subtotal = ref.watch(cartSubtotalProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Your ',
                style: AppTextStyles.headingBold.copyWith(fontSize: 20),
              ),
              TextSpan(
                text: 'Cart',
                style: AppTextStyles.headingSerif.copyWith(fontSize: 22),
              ),
            ],
          ),
        ),
      ),
      body: items.isEmpty
          ? const _EmptyCart()
          : _CartContent(items: items, subtotal: subtotal),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.shopping_bag_outlined,
              size: 64,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 16),
            Text(
              'Your cart is empty',
              style: AppTextStyles.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add meals or a subscription plan to get started.',
              style: AppTextStyles.bodyMuted,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'Browse Menu',
              onPressed: () => context.go('/menu'),
              variant: AppButtonVariant.secondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _CartContent extends ConsumerStatefulWidget {
  const _CartContent({required this.items, required this.subtotal});

  final List items;
  final int subtotal;

  @override
  ConsumerState<_CartContent> createState() => _CartContentState();
}

class _CartContentState extends ConsumerState<_CartContent> {
  final _promoController = TextEditingController();

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(cartProvider.notifier);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ...widget.items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: CartItemTile(
              item: item,
              onIncrement: () => notifier.increment(item.cartId),
              onDecrement: () => notifier.decrement(item.cartId),
              onRemove: () => notifier.remove(item.cartId),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Promo code — wired in Phase 3-2
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _promoController,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: 'Promo code',
                  hintStyle: AppTextStyles.bodyMuted,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(2),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(2),
                    borderSide: const BorderSide(color: AppColors.olive),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            AppButton(
              label: 'Apply',
              onPressed: null, // Phase 3-2
              variant: AppButtonVariant.secondary,
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Order summary
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cream,
            borderRadius: BorderRadius.circular(2),
          ),
          child: Column(
            children: [
              _SummaryRow(label: 'Subtotal', value: 'Rs. ${widget.subtotal}'),
              const SizedBox(height: 8),
              const _SummaryRow(label: 'Delivery', value: 'Free'),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Divider(color: AppColors.border, height: 1),
              ),
              _SummaryRow(
                label: 'Total',
                value: 'Rs. ${widget.subtotal}',
                bold: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        AppButton(
          label: 'Proceed to Checkout',
          onPressed: () => context.push('/checkout'),
          variant: AppButtonVariant.primary,
          fullWidth: true,
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyles.inter(
      fontSize: bold ? 16 : 14,
      fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
      color: AppColors.textPrimary,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(value, style: style),
      ],
    );
  }
}
