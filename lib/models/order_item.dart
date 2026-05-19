// lib/models/order_item.dart
// Represents a single line item within an order — either a meal or a meal plan.
// The item name is joined from the meals or subscription_plans table when fetched.

/// A single line item in a past order.
class OrderItem {
  const OrderItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unitPricePkr,
    required this.lineTotalPkr,
    this.mealId,
    this.planId,
  });

  /// Unique ID of this order item row.
  final String id;

  /// The name of the meal or plan — joined from the meals/subscription_plans table.
  final String name;

  /// How many units of this item were ordered.
  final int quantity;

  /// Price per unit in Pakistani Rupees.
  final int unitPricePkr;

  /// Total price for this line (quantity × unitPrice) in PKR.
  final int lineTotalPkr;

  /// The meal ID if this item is a meal (null for plan items).
  final String? mealId;

  /// The plan ID if this item is a subscription plan (null for meal items).
  final String? planId;

  /// Creates an OrderItem from a Supabase row.
  /// The row must include a nested 'meals' or 'subscription_plans' map
  /// (from a PostgREST join) so the item name can be extracted.
  factory OrderItem.fromMap(Map<String, dynamic> map) {
    // Extract the item name from whichever nested table was joined.
    final mealName =
        (map['meals'] as Map<String, dynamic>?)?['name'] as String?;
    final planName =
        (map['subscription_plans'] as Map<String, dynamic>?)?['name']
            as String?;

    return OrderItem(
      id: map['id'] as String,
      mealId: map['meal_id'] as String?,
      planId: map['plan_id'] as String?,
      name: mealName ?? planName ?? 'Item',
      quantity: map['quantity'] as int,
      unitPricePkr: map['unit_price_pkr'] as int,
      lineTotalPkr: map['line_total_pkr'] as int,
    );
  }
}
