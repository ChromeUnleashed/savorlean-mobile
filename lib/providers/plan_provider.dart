import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/subscription_plan.dart';
import '../services/plan_service.dart';

part 'plan_provider.g.dart';

@riverpod
PlanService planService(Ref ref) {
  return PlanService(Supabase.instance.client);
}

@riverpod
Future<List<SubscriptionPlan>> plans(Ref ref) async {
  return ref.watch(planServiceProvider).fetchPlans();
}

@riverpod
Future<List<SubscriptionPlan>> featuredPlans(Ref ref) async {
  return ref.watch(planServiceProvider).fetchFeaturedPlans();
}

@riverpod
Future<SubscriptionPlan?> planBySlug(Ref ref, String slug) async {
  return ref.watch(planServiceProvider).fetchPlanBySlug(slug);
}
