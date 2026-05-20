import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/category.dart';
import '../models/meal.dart';

class MealService {
  final SupabaseClient _client;

  MealService(this._client);

  static const _mealSelect =
      '*, categories!meals_category_id_fkey(id, name, slug)';

  Future<List<Category>> fetchCategories() async {
    final data = await _client
        .from('categories')
        .select()
        .eq('is_active', true)
        .order('sort_order');
    return (data as List).map((e) => Category.fromJson(e)).toList();
  }

  Future<List<Meal>> fetchMeals({String? categoryId}) async {
    final List data;
    if (categoryId != null) {
      data = await _client
          .from('meals')
          .select(_mealSelect)
          .eq('is_available', true)
          .eq('category_id', categoryId)
          .order('name')
          .limit(100);
    } else {
      data = await _client
          .from('meals')
          .select(_mealSelect)
          .eq('is_available', true)
          .order('name')
          .limit(100);
    }
    return data.map((e) => Meal.fromJson(e)).toList();
  }

  Future<List<Meal>> fetchFeaturedMeals() async {
    final data = await _client
        .from('meals')
        .select(_mealSelect)
        .eq('is_available', true)
        .eq('is_featured', true)
        .limit(10)
        .order('name');
    return (data as List).map((e) => Meal.fromJson(e)).toList();
  }

  Future<Meal?> fetchMealBySlug(String slug) async {
    final data = await _client
        .from('meals')
        .select(_mealSelect)
        .eq('slug', slug)
        .maybeSingle();
    if (data == null) return null;
    return Meal.fromJson(data);
  }
}
