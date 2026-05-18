// lib/screens/order_confirmation/order_confirmation_screen.dart
// Shown after a successful order placement.
// Displays the order number, summary, and a "Back to Home" button.
// Fully implemented in Phase 3-3.

import 'package:flutter/material.dart';

/// Order confirmation screen — Phase 3-3 stub.
class OrderConfirmationScreen extends StatelessWidget {
  const OrderConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order Confirmed')),
      body: const Center(child: Text('Order Confirmation — Phase 3-3')),
    );
  }
}
