import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/promo_code.dart';
import '../../providers/cart_provider.dart';
import '../../services/promo_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/cart_item_tile/cart_item_tile.dart';
import '../../widgets/common/app_button.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(cartProvider);

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
      body: items.isEmpty ? const _EmptyCart() : const _CartContent(),
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
  const _CartContent();

  @override
  ConsumerState<_CartContent> createState() => _CartContentState();
}

class _CartContentState extends ConsumerState<_CartContent> {
  final _promoController = TextEditingController();
  bool _isApplying = false;
  String? _promoError;

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  Future<void> _applyPromo() async {
    final code = _promoController.text.trim();
    if (code.isEmpty) return;

    setState(() {
      _isApplying = true;
      _promoError = null;
    });

    try {
      final promo = await ref.read(promoServiceProvider).validate(code);
      ref.read(appliedPromoProvider.notifier).apply(promo);
      _promoController.clear();
    } on PromoException catch (e) {
      setState(() => _promoError = e.message);
    } catch (_) {
      setState(() => _promoError = 'Could not apply promo code. Try again.');
    } finally {
      if (mounted) setState(() => _isApplying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(cartProvider);
    final subtotal = ref.watch(cartSubtotalProvider);
    final discount = ref.watch(cartDiscountProvider);
    final total = ref.watch(cartTotalProvider);
    final appliedPromo = ref.watch(appliedPromoProvider);
    final notifier = ref.read(cartProvider.notifier);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ...items.map(
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

        // Promo code section
        if (appliedPromo != null)
          _AppliedPromoChip(promo: appliedPromo)
        else ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
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
                          borderSide: BorderSide(
                            color: _promoError != null
                                ? AppColors.error
                                : AppColors.border,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(2),
                          borderSide: BorderSide(
                            color: _promoError != null
                                ? AppColors.error
                                : AppColors.olive,
                          ),
                        ),
                      ),
                      onChanged: (_) {
                        if (_promoError != null) {
                          setState(() => _promoError = null);
                        }
                      },
                    ),
                    if (_promoError != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        _promoError!,
                        style: AppTextStyles.inter(
                          fontSize: 12,
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              AppButton(
                label: 'Apply',
                onPressed: _isApplying ? null : _applyPromo,
                isLoading: _isApplying,
                variant: AppButtonVariant.secondary,
              ),
            ],
          ),
        ],
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
              _SummaryRow(label: 'Subtotal', value: 'Rs. $subtotal'),
              if (discount > 0) ...[
                const SizedBox(height: 8),
                _SummaryRow(
                  label: appliedPromo != null
                      ? 'Discount (${appliedPromo.code})'
                      : 'Discount',
                  value: '− Rs. $discount',
                  valueColor: AppColors.success,
                ),
              ],
              const SizedBox(height: 8),
              const _SummaryRow(label: 'Delivery', value: 'Free'),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Divider(color: AppColors.border, height: 1),
              ),
              _SummaryRow(label: 'Total', value: 'Rs. $total', bold: true),
            ],
          ),
        ),
        const SizedBox(height: 20),

        AppButton(
          label: 'Proceed to Checkout',
          onPressed: () => context.push('/checkout'),
          variant: AppButtonVariant.ctaLight,
          fullWidth: true,
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _AppliedPromoChip extends ConsumerWidget {
  const _AppliedPromoChip({required this.promo});

  final PromoCode promo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.oliveSoft,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: AppColors.olive),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 18,
            color: AppColors.olive,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  promo.code,
                  style: AppTextStyles.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.olive,
                  ),
                ),
                Text(
                  promo.displayLabel,
                  style: AppTextStyles.inter(
                    fontSize: 12,
                    color: AppColors.olive,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => ref.read(appliedPromoProvider.notifier).clear(),
            child: Text(
              'Remove',
              style: AppTextStyles.inter(fontSize: 12, color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.bold = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool bold;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final baseStyle = AppTextStyles.inter(
      fontSize: bold ? 16 : 14,
      fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
      color: AppColors.textPrimary,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: baseStyle),
        Text(
          value,
          style: valueColor != null
              ? baseStyle.copyWith(color: valueColor)
              : baseStyle,
        ),
      ],
    );
  }
}
