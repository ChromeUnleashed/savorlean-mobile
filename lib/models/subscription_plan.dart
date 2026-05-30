const _durationLabels = {
  '1_week': '1 Week',
  '2_weeks': '2 Weeks',
  '1_month': '1 Month',
};

const _durationOrder = ['1_week', '2_weeks', '1_month'];

class PlanPricing {
  final String id;
  final String planId;
  final String duration;
  final int mealsPerDay;
  final int pricePkr;

  const PlanPricing({
    required this.id,
    required this.planId,
    required this.duration,
    required this.mealsPerDay,
    required this.pricePkr,
  });

  String get durationLabel => _durationLabels[duration] ?? duration;

  factory PlanPricing.fromJson(Map<String, dynamic> json) {
    return PlanPricing(
      id: json['id'] as String,
      planId: json['plan_id'] as String,
      duration: json['duration'] as String,
      mealsPerDay: json['meals_per_day'] as int,
      pricePkr: json['price_pkr'] as int,
    );
  }
}

class PlanMealSlot {
  final String id;
  final String planId;
  final String day;
  final String slot;
  final String mealId;
  final String? mealName;
  final List<String> mealImages;

  const PlanMealSlot({
    required this.id,
    required this.planId,
    required this.day,
    required this.slot,
    required this.mealId,
    this.mealName,
    required this.mealImages,
  });

  String? get mealImageUrl => mealImages.isNotEmpty ? mealImages.first : null;

  factory PlanMealSlot.fromJson(Map<String, dynamic> json) {
    final meal = json['meals'] as Map<String, dynamic>?;
    return PlanMealSlot(
      id: json['id'] as String,
      planId: json['plan_id'] as String,
      day: json['day'] as String,
      slot: json['slot'] as String,
      mealId: json['meal_id'] as String,
      mealName: meal?['name'] as String?,
      mealImages: meal != null
          ? List<String>.from(meal['images'] as List? ?? [])
          : [],
    );
  }
}

class SubscriptionPlan {
  final String id;
  final String slug;
  final String name;
  final String type;
  final String description;
  final String scheduleMode;
  final String scheduleMessage;
  final bool isActive;
  final bool isFeatured;
  final String? imageUrl;
  final List<PlanPricing> pricing;
  final List<PlanMealSlot> slots;

  const SubscriptionPlan({
    required this.id,
    required this.slug,
    required this.name,
    required this.type,
    required this.description,
    required this.scheduleMode,
    required this.scheduleMessage,
    required this.isActive,
    required this.isFeatured,
    this.imageUrl,
    required this.pricing,
    required this.slots,
  });

  int? get startingPrice => pricing.isEmpty
      ? null
      : pricing.map((p) => p.pricePkr).reduce((a, b) => a < b ? a : b);

  List<String> get availableDurations =>
      _durationOrder.where((d) => pricing.any((p) => p.duration == d)).toList();

  List<int> get availableMealsPerDay {
    final set = pricing.map((p) => p.mealsPerDay).toSet().toList();
    set.sort();
    return set;
  }

  PlanPricing? pricingFor(String duration, int mealsPerDay) {
    final matches = pricing.where(
      (p) => p.duration == duration && p.mealsPerDay == mealsPerDay,
    );
    return matches.isEmpty ? null : matches.first;
  }

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    final pricingJson = json['plan_pricing'] as List? ?? [];
    final slotsJson = json['plan_meal_slots'] as List? ?? [];
    return SubscriptionPlan(
      id: json['id'] as String,
      slug: json['slug'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      description: json['description'] as String,
      scheduleMode: json['schedule_mode'] as String,
      scheduleMessage: json['schedule_message'] as String,
      isActive: json['is_active'] as bool,
      isFeatured: json['is_featured'] as bool,
      imageUrl: json['image_url'] as String?,
      pricing: pricingJson.map((e) => PlanPricing.fromJson(e)).toList(),
      slots: slotsJson.map((e) => PlanMealSlot.fromJson(e)).toList(),
    );
  }
}
