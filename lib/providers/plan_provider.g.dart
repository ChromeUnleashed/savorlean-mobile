// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plan_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(planService)
final planServiceProvider = PlanServiceProvider._();

final class PlanServiceProvider
    extends $FunctionalProvider<PlanService, PlanService, PlanService>
    with $Provider<PlanService> {
  PlanServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'planServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$planServiceHash();

  @$internal
  @override
  $ProviderElement<PlanService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PlanService create(Ref ref) {
    return planService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlanService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlanService>(value),
    );
  }
}

String _$planServiceHash() => r'35facfdf82134779ee69a2e2081b9142b9552fba';

@ProviderFor(plans)
final plansProvider = PlansProvider._();

final class PlansProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SubscriptionPlan>>,
          List<SubscriptionPlan>,
          FutureOr<List<SubscriptionPlan>>
        >
    with
        $FutureModifier<List<SubscriptionPlan>>,
        $FutureProvider<List<SubscriptionPlan>> {
  PlansProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'plansProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$plansHash();

  @$internal
  @override
  $FutureProviderElement<List<SubscriptionPlan>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SubscriptionPlan>> create(Ref ref) {
    return plans(ref);
  }
}

String _$plansHash() => r'46cbc151f6f89487b2e955ac9e0be52a28d463d7';

@ProviderFor(featuredPlans)
final featuredPlansProvider = FeaturedPlansProvider._();

final class FeaturedPlansProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SubscriptionPlan>>,
          List<SubscriptionPlan>,
          FutureOr<List<SubscriptionPlan>>
        >
    with
        $FutureModifier<List<SubscriptionPlan>>,
        $FutureProvider<List<SubscriptionPlan>> {
  FeaturedPlansProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'featuredPlansProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$featuredPlansHash();

  @$internal
  @override
  $FutureProviderElement<List<SubscriptionPlan>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SubscriptionPlan>> create(Ref ref) {
    return featuredPlans(ref);
  }
}

String _$featuredPlansHash() => r'b11a061d6e1a5927e7f0e1a5450e2e1f07913ec8';

@ProviderFor(planBySlug)
final planBySlugProvider = PlanBySlugFamily._();

final class PlanBySlugProvider
    extends
        $FunctionalProvider<
          AsyncValue<SubscriptionPlan?>,
          SubscriptionPlan?,
          FutureOr<SubscriptionPlan?>
        >
    with
        $FutureModifier<SubscriptionPlan?>,
        $FutureProvider<SubscriptionPlan?> {
  PlanBySlugProvider._({
    required PlanBySlugFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'planBySlugProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$planBySlugHash();

  @override
  String toString() {
    return r'planBySlugProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<SubscriptionPlan?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SubscriptionPlan?> create(Ref ref) {
    final argument = this.argument as String;
    return planBySlug(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PlanBySlugProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$planBySlugHash() => r'ba08aabfbb18032f3d5ca8f3c1c3dfab9170ea58';

final class PlanBySlugFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<SubscriptionPlan?>, String> {
  PlanBySlugFamily._()
    : super(
        retry: null,
        name: r'planBySlugProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PlanBySlugProvider call(String slug) =>
      PlanBySlugProvider._(argument: slug, from: this);

  @override
  String toString() => r'planBySlugProvider';
}
