// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(mealService)
final mealServiceProvider = MealServiceProvider._();

final class MealServiceProvider
    extends $FunctionalProvider<MealService, MealService, MealService>
    with $Provider<MealService> {
  MealServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mealServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mealServiceHash();

  @$internal
  @override
  $ProviderElement<MealService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MealService create(Ref ref) {
    return mealService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MealService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MealService>(value),
    );
  }
}

String _$mealServiceHash() => r'1b0872ed8d3a60f6182b60943899edf12cbbfb5e';

@ProviderFor(categories)
final categoriesProvider = CategoriesProvider._();

final class CategoriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Category>>,
          List<Category>,
          FutureOr<List<Category>>
        >
    with $FutureModifier<List<Category>>, $FutureProvider<List<Category>> {
  CategoriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'categoriesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$categoriesHash();

  @$internal
  @override
  $FutureProviderElement<List<Category>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Category>> create(Ref ref) {
    return categories(ref);
  }
}

String _$categoriesHash() => r'ad432cf72544f89ca8f7e5fd11c0c9375ba12bc0';

@ProviderFor(SelectedCategoryId)
final selectedCategoryIdProvider = SelectedCategoryIdProvider._();

final class SelectedCategoryIdProvider
    extends $NotifierProvider<SelectedCategoryId, String?> {
  SelectedCategoryIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedCategoryIdProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedCategoryIdHash();

  @$internal
  @override
  SelectedCategoryId create() => SelectedCategoryId();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$selectedCategoryIdHash() =>
    r'e200877d189e9efa39b0a04655f56101e28aaf21';

abstract class _$SelectedCategoryId extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(meals)
final mealsProvider = MealsProvider._();

final class MealsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Meal>>,
          List<Meal>,
          FutureOr<List<Meal>>
        >
    with $FutureModifier<List<Meal>>, $FutureProvider<List<Meal>> {
  MealsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mealsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mealsHash();

  @$internal
  @override
  $FutureProviderElement<List<Meal>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Meal>> create(Ref ref) {
    return meals(ref);
  }
}

String _$mealsHash() => r'a987919d92d4cb6f0e1a0afe15e1002d132bdf55';

@ProviderFor(featuredMeals)
final featuredMealsProvider = FeaturedMealsProvider._();

final class FeaturedMealsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Meal>>,
          List<Meal>,
          FutureOr<List<Meal>>
        >
    with $FutureModifier<List<Meal>>, $FutureProvider<List<Meal>> {
  FeaturedMealsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'featuredMealsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$featuredMealsHash();

  @$internal
  @override
  $FutureProviderElement<List<Meal>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Meal>> create(Ref ref) {
    return featuredMeals(ref);
  }
}

String _$featuredMealsHash() => r'f9cb0b68b2fb91254f402ea87a8baeb3a08db827';
