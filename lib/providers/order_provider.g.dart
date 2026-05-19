// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the list of past orders for the currently signed-in user.
/// Returns an empty list if no user is signed in.
/// Re-fetches automatically when auth state changes.

@ProviderFor(userOrders)
final userOrdersProvider = UserOrdersProvider._();

/// Provides the list of past orders for the currently signed-in user.
/// Returns an empty list if no user is signed in.
/// Re-fetches automatically when auth state changes.

final class UserOrdersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Order>>,
          List<Order>,
          FutureOr<List<Order>>
        >
    with $FutureModifier<List<Order>>, $FutureProvider<List<Order>> {
  /// Provides the list of past orders for the currently signed-in user.
  /// Returns an empty list if no user is signed in.
  /// Re-fetches automatically when auth state changes.
  UserOrdersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userOrdersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userOrdersHash();

  @$internal
  @override
  $FutureProviderElement<List<Order>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Order>> create(Ref ref) {
    return userOrders(ref);
  }
}

String _$userOrdersHash() => r'77a1383b0d61e8ef6e77a7cd334c90c32888cdd9';

/// Provides the full detail of a single order by its ID.
/// Includes all order items with their names joined from the database.
/// The [orderId] parameter makes this a "family" provider — a separate
/// instance is created for each unique order ID.

@ProviderFor(orderDetail)
final orderDetailProvider = OrderDetailFamily._();

/// Provides the full detail of a single order by its ID.
/// Includes all order items with their names joined from the database.
/// The [orderId] parameter makes this a "family" provider — a separate
/// instance is created for each unique order ID.

final class OrderDetailProvider
    extends $FunctionalProvider<AsyncValue<Order>, Order, FutureOr<Order>>
    with $FutureModifier<Order>, $FutureProvider<Order> {
  /// Provides the full detail of a single order by its ID.
  /// Includes all order items with their names joined from the database.
  /// The [orderId] parameter makes this a "family" provider — a separate
  /// instance is created for each unique order ID.
  OrderDetailProvider._({
    required OrderDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'orderDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$orderDetailHash();

  @override
  String toString() {
    return r'orderDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Order> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Order> create(Ref ref) {
    final argument = this.argument as String;
    return orderDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is OrderDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$orderDetailHash() => r'dc039a57931e4fec2dac57c07eb3fbf950afff39';

/// Provides the full detail of a single order by its ID.
/// Includes all order items with their names joined from the database.
/// The [orderId] parameter makes this a "family" provider — a separate
/// instance is created for each unique order ID.

final class OrderDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Order>, String> {
  OrderDetailFamily._()
    : super(
        retry: null,
        name: r'orderDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provides the full detail of a single order by its ID.
  /// Includes all order items with their names joined from the database.
  /// The [orderId] parameter makes this a "family" provider — a separate
  /// instance is created for each unique order ID.

  OrderDetailProvider call(String orderId) =>
      OrderDetailProvider._(argument: orderId, from: this);

  @override
  String toString() => r'orderDetailProvider';
}
