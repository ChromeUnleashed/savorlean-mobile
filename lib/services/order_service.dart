import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/cart_item.dart';
import '../models/placed_order.dart';

class OrderService {
  final SupabaseClient _client;
  OrderService(this._client);

  Future<PlacedOrder> placeOrder({
    required String email,
    required String? userId,
    required List<CartItem> items,
    required int subtotalPkr,
    required int discountPkr,
    required int totalPkr,
    required String paymentMethod,
    required String fullName,
    required String phoneNumber,
    required String streetAddress,
    required String areaZone,
    required String city,
    required String mealInstructions,
    String? preferredStartDate,
    String? timeWindow,
  }) async {
    final orderRow = await _client
        .from('orders')
        .insert({
          'user_id': userId,
          'email': email,
          'subtotal_pkr': subtotalPkr,
          'delivery_fee_pkr': 0,
          'discount_pkr': discountPkr,
          'total_pkr': totalPkr,
          'payment_method': paymentMethod,
          'meal_instructions': mealInstructions,
          'shipping_full_name': fullName,
          'shipping_phone_number': phoneNumber,
          'shipping_street_address': streetAddress,
          'shipping_area_zone': areaZone,
          'shipping_city': city,
          if (preferredStartDate != null && preferredStartDate.isNotEmpty)
            'shipping_preferred_start_date': preferredStartDate,
          if (timeWindow != null && timeWindow.isNotEmpty)
            'shipping_time_window': timeWindow,
        })
        .select('id')
        .single();

    final orderId = orderRow['id'] as String;

    final orderItems = items.map((item) {
      final row = <String, dynamic>{
        'order_id': orderId,
        'meal_id': item.mealId,
        'plan_id': item.planId,
        'quantity': item.quantity,
        'unit_price_pkr': item.unitPricePkr,
        'line_total_pkr': item.lineTotalPkr,
      };
      if (item.planId != null) {
        row['plan_config'] = {
          'duration': item.planDuration,
          'meals_per_day': item.planMealsPerDay,
        };
      }
      return row;
    }).toList();

    await _client.from('order_items').insert(orderItems);

    // Fire-and-forget: send confirmation email via Edge Function.
    // Wrapped in try/catch so an email failure never blocks the order confirmation.
    try {
      await _client.functions.invoke(
        'send-order-confirmation',
        body: {'order_id': orderId},
      );
    } catch (_) {
      // Email failure is non-fatal — order is already placed.
    }

    return PlacedOrder(
      id: orderId,
      totalPkr: totalPkr,
      paymentMethod: paymentMethod,
      itemCount: items.fold(0, (sum, i) => sum + i.quantity),
    );
  }
}
