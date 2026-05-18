import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/category.dart';
import '../models/meal.dart';
import '../services/meal_service.dart';

part 'meal_provider.g.dart';

@riverpod
MealService mealService(Ref ref) {
  return MealService(Supabase.instance.client);
}

@riverpod
Future<List<Category>> categories(Ref ref) async {
  return ref.watch(mealServiceProvider).fetchCategories();
}

@riverpod
class SelectedCategoryId extends _$SelectedCategoryId {
  @override
  String? build() => null;

  void select(String? id) => state = id;
}

@riverpod
Future<List<Meal>> meals(Ref ref) async {
  final categoryId = ref.watch(selectedCategoryIdProvider);
  return ref.watch(mealServiceProvider).fetchMeals(categoryId: categoryId);
}

@riverpod
Future<List<Meal>> featuredMeals(Ref ref) async {
  return ref.watch(mealServiceProvider).fetchFeaturedMeals();
}
