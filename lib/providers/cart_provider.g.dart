// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Cart)
final cartProvider = CartProvider._();

final class CartProvider extends $NotifierProvider<Cart, List<CartItem>> {
  CartProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cartProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cartHash();

  @$internal
  @override
  Cart create() => Cart();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<CartItem> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<CartItem>>(value),
    );
  }
}

String _$cartHash() => r'5984ff296fa2a5627aba8b5d174d09cdb8caa124';

abstract class _$Cart extends $Notifier<List<CartItem>> {
  List<CartItem> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<CartItem>, List<CartItem>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<CartItem>, List<CartItem>>,
              List<CartItem>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(AppliedPromo)
final appliedPromoProvider = AppliedPromoProvider._();

final class AppliedPromoProvider
    extends $NotifierProvider<AppliedPromo, PromoCode?> {
  AppliedPromoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appliedPromoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appliedPromoHash();

  @$internal
  @override
  AppliedPromo create() => AppliedPromo();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PromoCode? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PromoCode?>(value),
    );
  }
}

String _$appliedPromoHash() => r'049d34f8b4f3d5bdd9492561696befc2dbdf7e77';

abstract class _$AppliedPromo extends $Notifier<PromoCode?> {
  PromoCode? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<PromoCode?, PromoCode?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PromoCode?, PromoCode?>,
              PromoCode?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(promoService)
final promoServiceProvider = PromoServiceProvider._();

final class PromoServiceProvider
    extends $FunctionalProvider<PromoService, PromoService, PromoService>
    with $Provider<PromoService> {
  PromoServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'promoServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$promoServiceHash();

  @$internal
  @override
  $ProviderElement<PromoService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PromoService create(Ref ref) {
    return promoService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PromoService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PromoService>(value),
    );
  }
}

String _$promoServiceHash() => r'82a75a62c0d732650bf11f2354e2034b7b352ced';

@ProviderFor(cartItemCount)
final cartItemCountProvider = CartItemCountProvider._();

final class CartItemCountProvider extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  CartItemCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cartItemCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cartItemCountHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return cartItemCount(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$cartItemCountHash() => r'cc94760fa481415b749d2ca5f3706ac401da300b';

@ProviderFor(cartSubtotal)
final cartSubtotalProvider = CartSubtotalProvider._();

final class CartSubtotalProvider extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  CartSubtotalProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cartSubtotalProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cartSubtotalHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return cartSubtotal(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$cartSubtotalHash() => r'9325830169434759e6c91263a5caa00fbd912cd6';

@ProviderFor(cartDiscount)
final cartDiscountProvider = CartDiscountProvider._();

final class CartDiscountProvider extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  CartDiscountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cartDiscountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cartDiscountHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return cartDiscount(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$cartDiscountHash() => r'f23321b25705cac7a1d776a8404fcc087adfbd02';

@ProviderFor(cartTotal)
final cartTotalProvider = CartTotalProvider._();

final class CartTotalProvider extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  CartTotalProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cartTotalProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cartTotalHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return cartTotal(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$cartTotalHash() => r'54003588dc24a618cefe64fe905f1535b4048acd';
