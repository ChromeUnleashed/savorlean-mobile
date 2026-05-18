// lib/screens/account/order_detail/order_detail_screen.dart
// Detailed view of a single past order.
// Shows items, delivery address, status, and total breakdown.
// Fully implemented in Phase 4-2.

import 'package:flutter/material.dart';

/// Order detail screen — Phase 4-2 stub.
///
/// [orderId] — the UUID of the order, passed from the router.
class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order Details')),
      body: Center(child: Text('Order Detail: $orderId — Phase 4-2')),
    );
  }
}
