// lib/screens/account/order_detail/order_detail_screen.dart
// Full detail view for a single past order.
// Shows every line item, the delivery address, status, and price breakdown.
// The order ID comes from the router path parameter (/account/orders/:id).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/order.dart';
import '../../../models/order_item.dart';
import '../../../providers/order_provider.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

/// Order detail screen — displays everything about one specific order.
class OrderDetailScreen extends ConsumerWidget {
  const OrderDetailScreen({super.key, required this.orderId});

  /// The UUID of the order to display, passed from the router.
  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the orderDetail provider for this specific order ID.
    final orderAsync = ref.watch(orderDetailProvider(orderId));

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        title: Text(
          // Show a short order reference in the title bar.
          'Order #${orderId.substring(0, 8).toUpperCase()}',
        ),
      ),
      body: orderAsync.when(
        // Spinner while loading order data.
        loading: () => const Center(child: CircularProgressIndicator()),

        // Error state with retry button.
        error: (_, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Could not load order details.',
                style: AppTextStyles.bodyMuted,
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => ref.invalidate(orderDetailProvider(orderId)),
                child: const Text('Try again'),
              ),
            ],
          ),
        ),

        // Main detail view once data is loaded.
        data: (order) => SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Status banner ─────────────────────────────────────────────
              _StatusBanner(status: order.status),
              const SizedBox(height: 24),

              // ── Order items ───────────────────────────────────────────────
              _SectionHeader(title: 'Items'),
              const SizedBox(height: 8),
              _ItemsCard(items: order.items),
              const SizedBox(height: 20),

              // ── Price breakdown ───────────────────────────────────────────
              _SectionHeader(title: 'Summary'),
              const SizedBox(height: 8),
              _SummaryCard(order: order),
              const SizedBox(height: 20),

              // ── Delivery details ──────────────────────────────────────────
              _SectionHeader(title: 'Delivery Details'),
              const SizedBox(height: 8),
              _DeliveryCard(order: order),
              const SizedBox(height: 20),

              // ── Meal instructions (only shown if the user entered any) ────
              if (order.mealInstructions?.isNotEmpty == true) ...[
                _SectionHeader(title: 'Meal Instructions'),
                const SizedBox(height: 8),
                _InfoCard(
                  child: Text(
                    order.mealInstructions!,
                    style: AppTextStyles.body,
                  ),
                ),
                const SizedBox(height: 20),
              ],

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

/// A full-width colored banner showing the current order status prominently.
class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);
    final label = _statusLabel(status);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Column(
        children: [
          Icon(_statusIcon(status), color: color, size: 28),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _statusLabel(String s) {
    switch (s) {
      case 'confirmed':
        return 'Order Confirmed';
      case 'preparing':
        return 'Being Prepared';
      case 'out_for_delivery':
        return 'Out for Delivery';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Pending';
    }
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'confirmed':
        return Colors.blue;
      case 'preparing':
        return Colors.teal;
      case 'out_for_delivery':
        return Colors.indigo;
      case 'delivered':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      default:
        return Colors.orange;
    }
  }

  IconData _statusIcon(String s) {
    switch (s) {
      case 'confirmed':
        return Icons.check_circle_outline;
      case 'preparing':
        return Icons.soup_kitchen_outlined;
      case 'out_for_delivery':
        return Icons.delivery_dining_outlined;
      case 'delivered':
        return Icons.verified_outlined;
      case 'cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.hourglass_empty_outlined;
    }
  }
}

/// Bold section title.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.inter(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.textMuted,
      ),
    );
  }
}

/// A white card with a subtle border used as a container for each section.
class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

/// Displays all line items in the order as a list of rows.
class _ItemsCard extends StatelessWidget {
  const _ItemsCard({required this.items});

  final List<OrderItem> items;

  @override
  Widget build(BuildContext context) {
    // If no items loaded (shouldn't happen on detail screen), show a placeholder.
    if (items.isEmpty) {
      return _InfoCard(
        child: Text('No items found.', style: AppTextStyles.bodyMuted),
      );
    }

    return _InfoCard(
      child: Column(
        children: [
          // Column headers
          Row(
            children: [
              Expanded(
                child: Text(
                  'Item',
                  style: AppTextStyles.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              Text(
                'QTY',
                style: AppTextStyles.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 72,
                child: Text(
                  'Price',
                  textAlign: TextAlign.right,
                  style: AppTextStyles.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 16),
          // One row per item.
          ...items.map((item) => _ItemRow(item: item)),
        ],
      ),
    );
  }
}

/// A single item row showing name, quantity, and line total.
class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.item});

  final OrderItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Item name — takes up all available space.
          Expanded(child: Text(item.name, style: AppTextStyles.body)),
          // Quantity.
          Text('${item.quantity}', style: AppTextStyles.body),
          const SizedBox(width: 16),
          // Line total.
          SizedBox(
            width: 72,
            child: Text(
              'Rs. ${_fmt(item.lineTotalPkr)}',
              textAlign: TextAlign.right,
              style: AppTextStyles.body,
            ),
          ),
        ],
      ),
    );
  }
}

/// Price breakdown card — subtotal, discount, delivery, and total.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      child: Column(
        children: [
          _PriceRow(label: 'Subtotal', amount: order.subtotalPkr),
          // Only show discount if one was applied.
          if (order.discountPkr > 0)
            _PriceRow(
              label: 'Discount',
              amount: -order.discountPkr,
              color: AppColors.success,
            ),
          // Only show delivery fee if non-zero.
          if (order.deliveryFeePkr > 0)
            _PriceRow(label: 'Delivery', amount: order.deliveryFeePkr),
          const Divider(height: 16),
          _PriceRow(label: 'Total', amount: order.totalPkr, bold: true),
          const SizedBox(height: 6),
          // Payment method label.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Payment', style: AppTextStyles.bodyMuted),
              Text(
                order.paymentMethod == 'bank_transfer'
                    ? 'Bank Transfer'
                    : 'Cash on Delivery',
                style: AppTextStyles.body,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A single row in the price breakdown showing a label and an amount.
class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.amount,
    this.color,
    this.bold = false,
  });

  final String label;
  final int amount;
  final Color? color;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    // Amounts can be negative (discount), so format the absolute value
    // and prefix with a minus sign if needed.
    final prefix = amount < 0 ? '−Rs. ' : 'Rs. ';
    final formatted = _fmt(amount.abs());
    final textColor = color ?? AppColors.textPrimary;
    final weight = bold ? FontWeight.w700 : FontWeight.w400;
    final size = bold ? 15.0 : 14.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.inter(
              fontSize: size,
              fontWeight: weight,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            '$prefix$formatted',
            style: AppTextStyles.inter(
              fontSize: size,
              fontWeight: weight,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Delivery address and timing details card.
class _DeliveryCard extends StatelessWidget {
  const _DeliveryCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DetailRow(icon: Icons.person_outline, value: order.shippingFullName),
          _DetailRow(
            icon: Icons.phone_outlined,
            value: order.shippingPhoneNumber,
          ),
          _DetailRow(
            icon: Icons.location_on_outlined,
            value: [
              order.shippingStreetAddress,
              order.shippingAreaZone,
              order.shippingCity,
            ].where((s) => s.isNotEmpty).join(', '),
          ),
          // Only show start date and time window if the user entered them.
          if (order.shippingPreferredStartDate?.isNotEmpty == true)
            _DetailRow(
              icon: Icons.calendar_today_outlined,
              value: 'Start: ${order.shippingPreferredStartDate}',
            ),
          if (order.shippingTimeWindow?.isNotEmpty == true)
            _DetailRow(
              icon: Icons.access_time_outlined,
              value: order.shippingTimeWindow!,
            ),
        ],
      ),
    );
  }
}

/// A single detail row with a leading icon and a text value.
class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.textMuted),
          const SizedBox(width: 10),
          Expanded(child: Text(value, style: AppTextStyles.body)),
        ],
      ),
    );
  }
}

/// Formats an integer PKR amount with a thousands separator.
/// e.g. 1200 → "1,200"
String _fmt(int pkr) {
  return pkr.toString().replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+$)'),
    (m) => '${m[1]},',
  );
}
