// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides a live stream of Supabase auth state changes.
/// Widgets that watch this will rebuild on every sign-in, sign-out,
/// or token refresh event.

@ProviderFor(authStateChanges)
final authStateChangesProvider = AuthStateChangesProvider._();

/// Provides a live stream of Supabase auth state changes.
/// Widgets that watch this will rebuild on every sign-in, sign-out,
/// or token refresh event.

final class AuthStateChangesProvider
    extends
        $FunctionalProvider<AsyncValue<AuthState>, AuthState, Stream<AuthState>>
    with $FutureModifier<AuthState>, $StreamProvider<AuthState> {
  /// Provides a live stream of Supabase auth state changes.
  /// Widgets that watch this will rebuild on every sign-in, sign-out,
  /// or token refresh event.
  AuthStateChangesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authStateChangesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authStateChangesHash();

  @$internal
  @override
  $StreamProviderElement<AuthState> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<AuthState> create(Ref ref) {
    return authStateChanges(ref);
  }
}

String _$authStateChangesHash() => r'f70173ace78aa05e6fe0b1126bad659790e73d3d';

/// Provides the currently signed-in Supabase User, or null if not signed in.
/// Re-evaluates automatically whenever the auth state changes.

@ProviderFor(currentUser)
final currentUserProvider = CurrentUserProvider._();

/// Provides the currently signed-in Supabase User, or null if not signed in.
/// Re-evaluates automatically whenever the auth state changes.

final class CurrentUserProvider extends $FunctionalProvider<User?, User?, User?>
    with $Provider<User?> {
  /// Provides the currently signed-in Supabase User, or null if not signed in.
  /// Re-evaluates automatically whenever the auth state changes.
  CurrentUserProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentUserProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentUserHash();

  @$internal
  @override
  $ProviderElement<User?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  User? create(Ref ref) {
    return currentUser(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(User? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<User?>(value),
    );
  }
}

String _$currentUserHash() => r'b1261bbe3d77a12ef76543ff919fbd5d6c0cb19a';
