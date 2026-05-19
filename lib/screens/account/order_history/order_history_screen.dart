// lib/screens/account/order_history/order_history_screen.dart
// Shows all past orders for the signed-in user, newest first.
// Each row shows the order date, a short order ID, the status badge, and the total.
// Tapping a row opens the full Order Detail screen.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../models/order.dart';
import '../../../providers/order_provider.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

/// Order history screen — lists all orders for the signed-in user.
class OrderHistoryScreen extends ConsumerWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the orders provider — rebuilds when data arrives or changes.
    final ordersAsync = ref.watch(userOrdersProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        title: const Text('My Orders'),
      ),
      body: ordersAsync.when(
        // Show a centered spinner while the list is loading.
        loading: () => const Center(child: CircularProgressIndicator()),

        // Show a friendly error message with a retry button on failure.
        error: (_, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Could not load orders.', style: AppTextStyles.bodyMuted),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => ref.invalidate(userOrdersProvider),
                child: const Text('Try again'),
              ),
            ],
          ),
        ),

        data: (orders) {
          // No orders yet — show an empty state illustration.
          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.receipt_long_outlined,
                    size: 64,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(height: 16),
                  Text('No orders yet', style: AppTextStyles.headingBold),
                  const SizedBox(height: 8),
                  Text(
                    'Your past orders will appear here.',
                    style: AppTextStyles.bodyMuted,
                  ),
                ],
              ),
            );
          }

          // Render the list of orders, newest first.
          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            itemCount: orders.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              return _OrderTile(
                order: orders[index],
                onTap: () =>
                    context.push('/account/orders/${orders[index].id}'),
              );
            },
          );
        },
      ),
    );
  }
}

/// A single row in the order history list.
/// Shows order reference, date, status badge, and total amount.
class _OrderTile extends StatelessWidget {
  const _OrderTile({required this.order, required this.onTap});

  final Order order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Format the order date as "19 May 2026".
    final dateStr = _formatDate(order.createdAt.toLocal());

    // Show only the first 8 characters of the UUID as the order reference.
    final ref = '#${order.id.substring(0, 8).toUpperCase()}';

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Left side — order reference and date.
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ref, style: AppTextStyles.body),
                    const SizedBox(height: 4),
                    Text(dateStr, style: AppTextStyles.bodyMuted),
                  ],
                ),
              ),

              // Right side — status badge and total.
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _StatusBadge(status: order.status),
                  const SizedBox(height: 6),
                  Text(
                    'Rs. ${_formatPrice(order.totalPkr)}',
                    style: AppTextStyles.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right,
                color: AppColors.textMuted,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A colored pill badge showing the order's current status.
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final label = _statusLabel(status);
    final color = _statusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  /// Human-readable label for each status value stored in the database.
  String _statusLabel(String status) {
    switch (status) {
      case 'confirmed':
        return 'Confirmed';
      case 'preparing':
        return 'Preparing';
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

  /// Color associated with each order status.
  Color _statusColor(String status) {
    switch (status) {
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
        return Colors.orange; // pending
    }
  }
}

/// Formats an integer PKR amount with a thousands separator.
/// e.g. 1200 → "1,200"
String _formatPrice(int pkr) {
  return pkr.toString().replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+$)'),
    (m) => '${m[1]},',
  );
}

/// Formats a DateTime as "19 May 2026" without needing the intl package.
String _formatDate(DateTime dt) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
}
