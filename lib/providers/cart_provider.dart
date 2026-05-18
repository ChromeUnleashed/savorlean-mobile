import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/cart_item.dart';
import '../models/meal.dart';
import '../models/subscription_plan.dart';

part 'cart_provider.g.dart';

@riverpod
class Cart extends _$Cart {
  @override
  List<CartItem> build() => const [];

  void addMeal(Meal meal, int qty) {
    final idx = state.indexWhere((i) => i.cartId == meal.id);
    if (idx >= 0) {
      state = [
        for (final item in state)
          if (item.cartId == meal.id)
            item.copyWith(quantity: item.quantity + qty)
          else
            item,
      ];
    } else {
      state = [
        ...state,
        CartItem(
          cartId: meal.id,
          mealId: meal.id,
          name: meal.name,
          imageUrl: meal.imageUrl,
          unitPricePkr: meal.pricePkr,
          quantity: qty,
        ),
      ];
    }
  }

  void addPlan(SubscriptionPlan plan, PlanPricing pricing) {
    final cartId = '${plan.id}_${pricing.duration}_${pricing.mealsPerDay}';
    final idx = state.indexWhere((i) => i.cartId == cartId);
    if (idx >= 0) {
      state = [
        for (final item in state)
          if (item.cartId == cartId)
            item.copyWith(quantity: item.quantity + 1)
          else
            item,
      ];
    } else {
      state = [
        ...state,
        CartItem(
          cartId: cartId,
          planId: plan.id,
          name: plan.name,
          unitPricePkr: pricing.pricePkr,
          quantity: 1,
          planDurationLabel: pricing.durationLabel,
          planMealsPerDay: pricing.mealsPerDay,
        ),
      ];
    }
  }

  void increment(String cartId) {
    state = [
      for (final item in state)
        if (item.cartId == cartId)
          item.copyWith(quantity: item.quantity + 1)
        else
          item,
    ];
  }

  void decrement(String cartId) {
    final item = state.firstWhere((i) => i.cartId == cartId);
    if (item.quantity <= 1) {
      remove(cartId);
    } else {
      state = [
        for (final i in state)
          if (i.cartId == cartId) i.copyWith(quantity: i.quantity - 1) else i,
      ];
    }
  }

  void remove(String cartId) {
    state = state.where((i) => i.cartId != cartId).toList();
  }

  void clear() => state = const [];
}

@riverpod
int cartItemCount(Ref ref) =>
    ref.watch(cartProvider).fold(0, (sum, item) => sum + item.quantity);

@riverpod
int cartSubtotal(Ref ref) =>
    ref.watch(cartProvider).fold(0, (sum, item) => sum + item.lineTotalPkr);
