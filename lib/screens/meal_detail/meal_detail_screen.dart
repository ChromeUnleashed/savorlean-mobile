// lib/screens/meal_detail/meal_detail_screen.dart
// Detailed view of a single meal.
// Shows hero image, nutrition facts, ingredients, and add-to-cart button.
// Fully implemented in Phase 2-3.

import 'package:flutter/material.dart';

/// Meal detail screen — Phase 2-3 stub.
///
/// [slug] — the URL-friendly identifier for the meal, passed from the router.
class MealDetailScreen extends StatelessWidget {
  const MealDetailScreen({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(slug)),
      body: Center(child: Text('Meal Detail: $slug — Phase 2-3')),
    );
  }
}
