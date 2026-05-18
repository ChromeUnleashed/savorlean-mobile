// lib/screens/plan_detail/plan_detail_screen.dart
// Detailed view of a single subscription meal plan.
// Shows plan name, duration, price, included meals, and add-to-cart button.
// Fully implemented in Phase 2-4.

import 'package:flutter/material.dart';

/// Plan detail screen — Phase 2-4 stub.
///
/// [slug] — the URL-friendly identifier for the plan, passed from the router.
class PlanDetailScreen extends StatelessWidget {
  const PlanDetailScreen({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(slug)),
      body: Center(child: Text('Plan Detail: $slug — Phase 2-4')),
    );
  }
}
