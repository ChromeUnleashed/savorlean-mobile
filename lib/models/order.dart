// lib/models/order.dart
// Represents a complete past order fetched from the Supabase 'orders' table.
// Used by the Order History and Order Detail screens.
// For the lightweight object created immediately after checkout, see placed_order.dart.

import 'order_item.dart';

/// A full order record including delivery details and line items.
class Order {
  const Order({
    required this.id,
    required this.createdAt,
    required this.subtotalPkr,
    required this.deliveryFeePkr,
    required this.discountPkr,
    required this.totalPkr,
    required this.status,
    required this.paymentMethod,
    required this.shippingFullName,
    required this.shippingPhoneNumber,
    required this.shippingStreetAddress,
    required this.shippingAreaZone,
    required this.shippingCity,
    this.shippingPreferredStartDate,
    this.shippingTimeWindow,
    this.mealInstructions,
    this.items = const [],
  });

  /// Unique UUID for this order (shown truncated in the UI).
  final String id;

  /// When the order was placed.
  final DateTime createdAt;

  /// Order subtotal before discount and delivery, in PKR.
  final int subtotalPkr;

  /// Delivery fee in PKR (currently always 0).
  final int deliveryFeePkr;

  /// Discount applied via promo code, in PKR.
  final int discountPkr;

  /// Final amount charged, in PKR.
  final int totalPkr;

  /// Current order status — e.g. 'pending', 'confirmed', 'delivered', 'cancelled'.
  final String status;

  /// How the customer paid — 'cod' or 'bank_transfer'.
  final String paymentMethod;

  final String shippingFullName;
  final String shippingPhoneNumber;
  final String shippingStreetAddress;
  final String shippingAreaZone;
  final String shippingCity;

  /// Optional preferred delivery start date (ISO date string).
  final String? shippingPreferredStartDate;

  /// Optional preferred delivery time window.
  final String? shippingTimeWindow;

  /// Optional meal instructions from the customer.
  final String? mealInstructions;

  /// The individual items in this order. Empty for list-view fetches.
  final List<OrderItem> items;

  /// Creates an Order from a Supabase row.
  /// If the row includes a nested 'order_items' list (from a PostgREST join),
  /// those are parsed into OrderItem objects. Otherwise items is empty.
  factory Order.fromMap(Map<String, dynamic> map) {
    // Parse the nested order_items list if it was included in the query.
    final rawItems = map['order_items'] as List<dynamic>? ?? [];

    return Order(
      id: map['id'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      subtotalPkr: map['subtotal_pkr'] as int,
      deliveryFeePkr: map['delivery_fee_pkr'] as int? ?? 0,
      discountPkr: map['discount_pkr'] as int? ?? 0,
      totalPkr: map['total_pkr'] as int,
      status: map['status'] as String? ?? 'pending',
      paymentMethod: map['payment_method'] as String? ?? 'cod',
      shippingFullName: map['shipping_full_name'] as String? ?? '',
      shippingPhoneNumber: map['shipping_phone_number'] as String? ?? '',
      shippingStreetAddress: map['shipping_street_address'] as String? ?? '',
      shippingAreaZone: map['shipping_area_zone'] as String? ?? '',
      shippingCity: map['shipping_city'] as String? ?? '',
      shippingPreferredStartDate:
          map['shipping_preferred_start_date'] as String?,
      shippingTimeWindow: map['shipping_time_window'] as String?,
      mealInstructions: map['meal_instructions'] as String?,
      items: rawItems
          .map((i) => OrderItem.fromMap(i as Map<String, dynamic>))
          .toList(),
    );
  }
}
