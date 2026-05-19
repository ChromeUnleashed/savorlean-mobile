// lib/providers/order_provider.dart
// Riverpod providers for fetching order history and order detail.
// Connects OrderService to the Order History and Order Detail screens.

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/order.dart';
import '../providers/auth_provider.dart';
import '../services/order_service.dart';

part 'order_provider.g.dart';

/// Provides the list of past orders for the currently signed-in user.
/// Returns an empty list if no user is signed in.
/// Re-fetches automatically when auth state changes.
@riverpod
Future<List<Order>> userOrders(Ref ref) async {
  // Watch the current user so the provider re-runs on sign-in/sign-out.
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];

  return OrderService(Supabase.instance.client).fetchOrders(user.id);
}

/// Provides the full detail of a single order by its ID.
/// Includes all order items with their names joined from the database.
/// The [orderId] parameter makes this a "family" provider — a separate
/// instance is created for each unique order ID.
@riverpod
Future<Order> orderDetail(Ref ref, String orderId) async {
  return OrderService(Supabase.instance.client).fetchOrderById(orderId);
}
