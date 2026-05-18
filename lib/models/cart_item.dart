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
    this.planDurationLabel,
    this.planMealsPerDay,
  });

  final String cartId;
  final String? mealId;
  final String? planId;
  final String name;
  final String? imageUrl;
  final int unitPricePkr;
  final int quantity;
  final String? planDurationLabel;
  final int? planMealsPerDay;

  int get lineTotalPkr => unitPricePkr * quantity;

  String get subtitle {
    if (planDurationLabel != null && planMealsPerDay != null) {
      return '$planDurationLabel · $planMealsPerDay meal${planMealsPerDay! > 1 ? 's' : ''}/day';
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
    planDurationLabel: planDurationLabel,
    planMealsPerDay: planMealsPerDay,
  );
}
