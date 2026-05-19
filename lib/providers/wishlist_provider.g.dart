// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wishlist_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Holds the set of meal IDs the signed-in user has wishlisted.
/// Returns an empty set when no user is signed in.
/// Watching currentUserProvider means this automatically re-runs on sign-in/out.

@ProviderFor(Wishlist)
final wishlistProvider = WishlistProvider._();

/// Holds the set of meal IDs the signed-in user has wishlisted.
/// Returns an empty set when no user is signed in.
/// Watching currentUserProvider means this automatically re-runs on sign-in/out.
final class WishlistProvider
    extends $AsyncNotifierProvider<Wishlist, Set<String>> {
  /// Holds the set of meal IDs the signed-in user has wishlisted.
  /// Returns an empty set when no user is signed in.
  /// Watching currentUserProvider means this automatically re-runs on sign-in/out.
  WishlistProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'wishlistProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$wishlistHash();

  @$internal
  @override
  Wishlist create() => Wishlist();
}

String _$wishlistHash() => r'7d3538c02e2ca17f9babc373433a8c32068ad016';

/// Holds the set of meal IDs the signed-in user has wishlisted.
/// Returns an empty set when no user is signed in.
/// Watching currentUserProvider means this automatically re-runs on sign-in/out.

abstract class _$Wishlist extends $AsyncNotifier<Set<String>> {
  FutureOr<Set<String>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Set<String>>, Set<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Set<String>>, Set<String>>,
              AsyncValue<Set<String>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
