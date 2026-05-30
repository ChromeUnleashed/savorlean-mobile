import 'package:flutter/foundation.dart';

@immutable
class CartItem {
  const CartItem({
    required this.cartId,
    this.mealId,
    this.planId,
    required this.name,
    this.imageUrl,
    required this.unitPricePkr,
    required this.quantity,
    this.planDuration,
    this.planDurationLabel,
    this.planMealsPerDay,
    this.planSelectedDays,
  });

  final String cartId;
  final String? mealId;
  final String? planId;
  final String name;
  final String? imageUrl;
  final int unitPricePkr;
  final int quantity;
  final String? planDuration; // raw key e.g. "1_week"
  final String? planDurationLabel; // human label e.g. "1 Week"
  final int? planMealsPerDay;

  // Which days of the week the customer selected for delivery (custom plans only).
  // Stored as lowercase day names e.g. ['monday', 'wednesday', 'friday'].
  final List<String>? planSelectedDays;

  int get lineTotalPkr => unitPricePkr * quantity;

  String get subtitle {
    if (planDurationLabel != null && planMealsPerDay != null) {
      final base =
          '$planDurationLabel · $planMealsPerDay meal${planMealsPerDay! > 1 ? 's' : ''}/day';
      if (planSelectedDays != null && planSelectedDays!.isNotEmpty) {
        // Show abbreviated day names e.g. "Mon, Wed, Fri"
        final days = planSelectedDays!
            .map((d) => d[0].toUpperCase() + d.substring(1, 3))
            .join(', ');
        return '$base · $days';
      }
      return base;
    }
    return '';
  }

  CartItem copyWith({int? quantity}) => CartItem(
    cartId: cartId,
    mealId: mealId,
    planId: planId,
    name: name,
    imageUrl: imageUrl,
    unitPricePkr: unitPricePkr,
    quantity: quantity ?? this.quantity,
    planDuration: planDuration,
    planDurationLabel: planDurationLabel,
    planMealsPerDay: planMealsPerDay,
    planSelectedDays: planSelectedDays,
  );
}
