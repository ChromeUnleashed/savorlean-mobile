// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides a singleton instance of the SettingsService.

@ProviderFor(settingsService)
final settingsServiceProvider = SettingsServiceProvider._();

/// Provides a singleton instance of the SettingsService.

final class SettingsServiceProvider
    extends
        $FunctionalProvider<SettingsService, SettingsService, SettingsService>
    with $Provider<SettingsService> {
  /// Provides a singleton instance of the SettingsService.
  SettingsServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsServiceHash();

  @$internal
  @override
  $ProviderElement<SettingsService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SettingsService create(Ref ref) {
    return settingsService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SettingsService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SettingsService>(value),
    );
  }
}

String _$settingsServiceHash() => r'90e70c23c9a280b6e4a35da900d0fd05f635d0e9';

/// Fetches all the data needed for the Home Screen concurrently.

@ProviderFor(homeData)
final homeDataProvider = HomeDataProvider._();

/// Fetches all the data needed for the Home Screen concurrently.

final class HomeDataProvider
    extends
        $FunctionalProvider<AsyncValue<HomeData>, HomeData, FutureOr<HomeData>>
    with $FutureModifier<HomeData>, $FutureProvider<HomeData> {
  /// Fetches all the data needed for the Home Screen concurrently.
  HomeDataProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeDataProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeDataHash();

  @$internal
  @override
  $FutureProviderElement<HomeData> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<HomeData> create(Ref ref) {
    return homeData(ref);
  }
}

String _$homeDataHash() => r'4bdfb6e212796407f2a9871b576b836da29f0492';
