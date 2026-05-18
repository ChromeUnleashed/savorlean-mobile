import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/subscription_plan.dart';

class PlanService {
  final SupabaseClient _client;

  PlanService(this._client);

  static const _planSelect = '*, plan_pricing(*)';
  static const _planDetailSelect =
      '*, plan_pricing(*), plan_meal_slots(*, meals(id, name, slug, images))';

  Future<List<SubscriptionPlan>> fetchPlans() async {
    final data = await _client
        .from('subscription_plans')
        .select(_planSelect)
        .eq('is_active', true)
        .order('name');
    return (data as List).map((e) => SubscriptionPlan.fromJson(e)).toList();
  }

  Future<List<SubscriptionPlan>> fetchFeaturedPlans() async {
    final data = await _client
        .from('subscription_plans')
        .select(_planSelect)
        .eq('is_active', true)
        .eq('is_featured', true)
        .limit(5)
        .order('name');
    return (data as List).map((e) => SubscriptionPlan.fromJson(e)).toList();
  }

  Future<SubscriptionPlan?> fetchPlanBySlug(String slug) async {
    final data = await _client
        .from('subscription_plans')
        .select(_planDetailSelect)
        .eq('slug', slug)
        .maybeSingle();
    if (data == null) return null;
    return SubscriptionPlan.fromJson(data);
  }
}
