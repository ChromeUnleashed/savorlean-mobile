// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(defaultAddress)
final defaultAddressProvider = DefaultAddressProvider._();

final class DefaultAddressProvider
    extends
        $FunctionalProvider<AsyncValue<Address?>, Address?, FutureOr<Address?>>
    with $FutureModifier<Address?>, $FutureProvider<Address?> {
  DefaultAddressProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'defaultAddressProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$defaultAddressHash();

  @$internal
  @override
  $FutureProviderElement<Address?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Address?> create(Ref ref) {
    return defaultAddress(ref);
  }
}

String _$defaultAddressHash() => r'f023fa0040426b75ae3c0c04c91b34f02e64b9b5';
